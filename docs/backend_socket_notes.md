# Backend socket integration

The mobile app expects to receive `newMessage` events via Socket.IO whenever a chat
message is created through the HTTP API. Currently `chat.service.js` stores the
message but does not emit an event. This causes the recipient to see messages
only after refreshing. To fix this, update the HTTP endpoint to broadcast the
message via `io.to(chatId).emit('newMessage', data)`.

```
// Example: chat.controller.js or chat.service.js
import { io } from '../index.js'; // ensure io is exported
...
export async function sendMessage(...) {
  const message = await prisma.chatMessage.create(...);
  io.to(chatId).emit('newMessage', serialize(message));
  ...
}
```
Ensure the Socket.IO server instance is accessible in your service layer.
