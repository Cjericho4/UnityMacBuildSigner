APP                 ?= BuildTitle #Do not do .app just do the title of your game.
VERSION             ?= VersionNumber #Something We use to keep the builds 
entitlements        ?= generic.entitlements
DEV_ID              ?= "Developer ID Application: <OrganizationName> ($(TEAM_ID))"
APPLE_ID            ?= your@apple.id
GEN_PW              ?= ojzb-qymy-qfbi-oilj
TEAM_ID             ?= 278M287E2K
UNITY_BUNDLE_ID     ?= com.Zygote.cAnatomy
USER 				?= id -un
SERVER_ADDRESS		?= exampleserver.com:/Path/To/AssetDownload

sign:
	@echo ‘Make Build Exectuable’
	@chmod -R a+xr $(APP).app
	@echo "Sign the application and any underlying DLLS"
	@echo ""
	@find ./$(APP).app -type f -exec codesign --timestamp --keychain /Users/$(USER)/Library/Keychains/login.keychain-db -s $(DEV_ID) -f --verbose=9 --deep --options=runtime --entitlements "generic.entitlements" {} +
	@codesign --timestamp --keychain /Users/$(USER)/Library/Keychains/login.keychain-db -s $(DEV_ID) -f --verbose=9 --deep --options=runtime --entitlements "generic.entitlements" $(APP).app
	@echo "Zip application to upload for notarization"
	@ditto --keepParent -c -k --sequesterRsrc "$(APP).app" "$(VERSION)cAnatomy.zip" 
	@echo "Upload to Apples Notarization service"
	@xcrun altool --notarize-app --username $(APPLE_ID) --password $(GEN_PW) --asc-provider $(TEAM_ID) --primary-bundle-id $(UNITY_BUNDLE_ID) --file $(VERSION).zip
staple:
	@echo "Stapling the notarization to the app"
	@xcrun stapler staple $(APP)
	@echo "Zipping the signed application to prepare for upload to server"
	@ditto --keepParent -c -k --sequesterRsrc "$(APP).app" "$(APP).zip"
# Optional part of the code, you can use this to upload to a website if you distribute through a website. If you distribute on steam you can ignore this.
	@while [ -z "$$CONTINUE"]; do \
		read -r -p "Would you like to upload to the server? Type y for yes, or n for no. [y/N]: " CONTINUE; \
	done ;\
	[  $(CONTINUE) = "y" ] || (scp $(VERSION).zip $(SERVER_ADDRESS);exit 1;)
	@echo "App has been signed successfullly. But not yet uploaded to the server. Please do so after testing has been completed."
	