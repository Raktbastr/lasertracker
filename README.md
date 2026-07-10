![Laser Tracker](https://raw.githubusercontent.com/Raktbastr/lasertracker/refs/heads/main/assets/tracker_logo-horizontal.png)

# Laser Tracker
A multiplatform application allowing FRC teams to track the statuses of thier members while at competitions. Developed by Team 2077 Laser Robotics.
### AI was not used in the creation of this project as per the Laser Robotics bylaws.

## How does it work?
A member of a team, creates a group along with thier username and password. That account is now the lead member of that group. This account is also given the group's 'join key'. It is suggested to have a mentor or coach use this account.

When a group is created, it is associated with a team and event, so new groups are required for each event a team participates in. This allows the app to show stats specific to your team, such as upcoming matches.

With the join key provided by the lead member, other members can now create an account inside the group.

The app tracks the following about each member
* Location (stands, cafeteria, pit, juding room)
* Job (drive team, impact team, pit crew)
* Role (drive team roles, safety captain)
* Status (in match, in judging, free)

## How does it work, technically?
Laser Tracker is built with Flutter. This allows the project to be ran on many different platforms such as the web and Android, both of which Laser Tracker is configured for.

The backend ([Laser Tracker Server](https://github.com/Raktbastr/lasertracker_server)) is a Python Flask app which manages a Sqlite database, proxies various requests to and from The Blue Alliance's APIv3, and hosts various API endpoints. The Sqlite database stores all the user and group information, while TBA handles team avatars, names, events, and match info.

Laser Robotics hosts an instance of Laser Tracker Server at https://api.lasertracker.laserrobotics.org, which serves as the default in the app.

## Planned features
* Live chat for each group
* Allowing lead member privledges for multiple users

## Installation and use
Laser Tracker does not require any installation and can be accessed at https://lasertracker.laserrobotics.org.

But for those who prefer, we provide APK files for Android users.

## Build/Hosting Instructions
### Laser Tracker
1. Make sure you have the Flutter SDK properly installed + Android tools if needed.
2. In the project root run `flutter pub get` to install any dependencies.
3. Run `flutter build <platform>` where platform is either `web` or `apk`
4. What to do with your build files.
    * Web: Host a webserver pointing to index.html.
    * apk: Install the apk either through adb or Android itself.
### Laser Tracker Server
1. Create an enter a Python virtual environment in the project root.
2. Install the required python packages with `pip install -r requirements.txt`.
3. Make a Blue Alliance read API key which can be done from the [account page](http://www.thebluealliance.com/account).
4. Run main.py, it will walk you through the inital settings. Paste in your api key when asked.
5. Make sure the server is accessible from the internet, and that Laser Tracker is configured to use it instead of the default. The server is ran by default on port 2077.