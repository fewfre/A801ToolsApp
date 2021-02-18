Since mac build are required to be created on a mac, and since bat files don't work on unix,
this bash sh file is a quick and dirty rework of all the bat files used in PackageApp.bat

Notes to consider:
- It currently expects my certificate to be inside this directory
- It expects the AIR SDK to be on the parent folder, and in a folder named `airsdk`