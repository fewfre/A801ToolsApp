package ext
{
	import flash.media.CameraRoll;
	import flash.events.PermissionEvent;
	import flash.permissions.PermissionStatus;
	import flash.display.BitmapData;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.filesystem.*;
	
	public class CameraRollSaver
	{
		private static var cameraRoll:CameraRoll = new CameraRoll();
		private static var docsDir: File = File.documentsDirectory;
		
		public static function saveToCameraRoll(pBitmap:BitmapData):void {
			if (CameraRoll.supportsAddBitmapData) {
				( new CameraRoll() ).addBitmapData(pBitmap);
			}
			return;
			
			// // try {
			// 	//always check if it's supported first (will be true for mobile, false for desktop)
			// 	if (CameraRoll.supportsAddBitmapData) {
					
			// 		//check if permission was already granted in a previous session:
			// 		if (CameraRoll.permissionStatus == PermissionStatus.GRANTED){
					
			// 			//safe to add, it will now appear in the device photos
			// 			cameraRoll.addBitmapData(pBitmap);
						
			// 		} else {
			// 			//need to request permission first
						
            //             /*
			// 			for iOS, you also need to set these keys in your iPhone InfoAdditions 
			// 			in the application XML or else THIS WILL NOT WORK:
						
			// 			<key>NSCameraUsageDescription</key>
			// 			<string>Required to save your images.</string>
			// 			<key>NSPhotoLibraryUsageDescription</key>
			// 			<string>Required to save your images.</string>
			// 			<key>NSPhotoLibraryAddUsageDescription</key>
			// 			<string>Required to save your images.</string>
			// 			*/
						
			// 			//listener for the user's response:
			// 			var permissionChanged:Function = function(e) : void{
			// 				if (e.status == PermissionStatus.GRANTED) {
								
			// 					//Permission was now granted by the user after prompting, run the command again now that it's allowed:
			// 					cameraRoll.addBitmapData(pBitmap);
								
			// 				}
			// 				cameraRoll.removeEventListener(PermissionEvent.PERMISSION_STATUS, permissionChanged);
			// 			};
			// 			cameraRoll.addEventListener(PermissionEvent.PERMISSION_STATUS, permissionChanged);
						
			// 			//request permission, will display the permission popup on their device:
			// 			cameraRoll.requestPermission();
			// 		}
					
			// 	} else {
			// 		//Camera Roll does not support addBitmapData.
			// 	}

			// } catch (err:Error) {
				
			// }

		}
		
		public static function saveToSystem(bytes:ByteArray) : void {
			docsDir = File.applicationDirectory
			docsDir.browseForSave("Save As");
			
			var onSelect:Function = function(event: Event): void {
				var newFile: File = event.target as File;
				if (!newFile.exists) // remove this 'if' if overwrite is OK.
				{
					var stream: FileStream = new FileStream();
					stream.open(newFile, FileMode.WRITE);
					stream.writeBytes(bytes);
					stream.close();
				} else trace('Selected path already exists.');
				docsDir.removeEventListener(Event.SELECT, onSelect);
			};
			docsDir.addEventListener(Event.SELECT, onSelect);
		}
	}
}