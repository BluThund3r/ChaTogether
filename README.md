# ChaTogether
## Overview 👁️
**ChaTogether** is an Android mobile app designed to offer the possibilities of text chatting with friends in a 🔒 secure environment (end-to-end encrypted messages), 📞 voice and video calls and 📺 watching YouTube videos in synced rooms.

This application was developed as a final project for my 🎓 undergraduate degree in Computer Science at the Faculty of Mathematics and Computer Science (University of Bucharest). For more in-depth information (in Romanian ⚠️), [here](https://github.com/BluThund3r/ChaTogether/blob/main/Licenta_Radu_George-Marian.pdf) is a link to my degree thesis that contains information about my app (partially; some features are not described in the thesis).

## Technologies Used 🛠️
I used modern and popular technologies for implementing both the backend and frontend sides of the app. 

On the **_backend_** side I used **Java** and **Spring** (**Spring Boot**) to build the actual server and the data is stored in two databases: a relational **MySQL** database and a document-based **MongoDB** database, both of them running in separate **Docker** containers for better isolation and portability. For real-time communication I used **Websocket** connections along with basic **HTTP** requests and responses.

On the **_frontend_** side I used **Dart** as the base programming language along with **Flutter** for building the mobile app.

## Main Features ❇️
A video demo that displays the functionalities of the mobile app can be found [here](https://www.youtube.com/watch?v=atHIn2uo5uw).

### Friend System
A user can interact with others only through the friend system implemented in the app. One can send friend requests, accept and cancel them, manage their friends and their blocked users. Users can only create private and group chats with their friends.

### End-to-end encrypted text chats
All text chats (private or group) benefit from end-to-end encryption using well-known cryptographic algorithms. The members of a chat can send text messages, edit, delete and restore them, copy the content of any message and send images from both gallery and camera. In the context of a group chat there are *chat admins* who can edit the group name, change the group picture and manage the members of the group.

### Calls
While in a chat, users can see in the top-right corner of the screen a button for joining a call with all the members in the conversation (for both private and group chats). The call screen provides useful information and buttons to access all the expected functionalities of a call. A history of all the calls from the chats that a user is part of is available in the **Calls** section of the home screen.

### YouTube video rooms
Anyone can create video rooms in the app and share the unique connection code with friends in order for them to join. Once joined, users can play, pause, seek and change the video, all these actions being in sync on each member's device.

### App Administrator 
The app administrators have access to a special section in the home screen. They can jump from here to the statistics screen that show important data about the app for the last 6 months in both numeric form and charts. Moreover, they can see a list of all the accounts and can grant or revoke admin rights and send confirmation mails to users that have not activated their accounts yet.
