package ext
{
	import flash.media.CameraRoll;
	import flash.filesystem.*;
	import flash.permissions.PermissionStatus;
	import flash.events.PermissionEvent;
	
	public class ParentAppSystem
	{
		// Prevent garbage collection, since this class is used in child swf, not this swf
		public static function start() : String {
			return "start";
		}
		
		public static function getCameraRollClass() : Class {
			return CameraRoll;
		}
		
		public static function getFileClass() : Class {
			return File;
		}
		
		public static function getFileStreamClass() : Class {
			return FileStream;
		}
		
		public static function getPermissionStatusClass() : Class {
			return PermissionStatus;
		}
		
		public static function getPermissionEventClass() : Class {
			return PermissionEvent;
		}
	}
}
