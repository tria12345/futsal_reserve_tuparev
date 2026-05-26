const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
app.use(express.json());

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// Store connected users/roles for logging
const activeUsers = new Map();

io.on('connection', (socket) => {
  console.log(`New socket connected: ${socket.id}`);

  // Handle joining a room (e.g. 'admins' or 'customers')
  socket.on('join_room', (room) => {
    socket.join(room);
    console.log(`Socket ${socket.id} joined room: ${room}`);
  });

  // Handle general messages from client
  socket.on('client_message', (data) => {
    console.log(`Received client message from ${socket.id}:`, data);
    // Broadcast to everyone else (excluding sender)
    socket.broadcast.emit('server_message', data);
  });

  // Handle client-side booking notification triggers (Customer → Admin)
  socket.on('new_booking_submitted', (data) => {
    console.log(`New booking submitted by client ${socket.id}:`, data);
    // Broadcast to all admins or all users, excluding the sender
    socket.broadcast.emit('booking_update', {
      type: 'new_booking',
      message: `New booking submitted by ${data.team_name || 'a customer'}!`,
      data: data
    });
  });

  // Handle admin verification events (Admin → Customer)
  socket.on('booking_verified', (data) => {
    console.log(`Booking verified by admin ${socket.id}:`, data);
    const statusLabel = data.status === 'approved' ? 'APPROVED ✅' : 'REJECTED ❌';
    // Broadcast to all clients except the admin who verified
    socket.broadcast.emit('verification_update', {
      type: 'booking_verified',
      status: data.status,
      booking_id: data.booking_id,
      team_name: data.team_name,
      message: `Booking for "${data.team_name || 'your team'}" has been ${statusLabel} by admin.`
    });
  });

  // Handle admin check-in events (Admin → Customer)
  socket.on('booking_checked_in', (data) => {
    console.log(`Booking checked-in by admin ${socket.id}:`, data);
    // Broadcast to all clients except the admin who checked in
    socket.broadcast.emit('verification_update', {
      type: 'booking_checked_in',
      status: 'checked_in',
      booking_id: data.booking_id,
      team_name: data.team_name,
      message: `Team "${data.team_name || 'your team'}" has been checked in! Enjoy your match! ⚽`
    });
  });

  socket.on('disconnect', () => {
    console.log(`Socket disconnected: ${socket.id}`);
  });
});

// HTTP REST route for PHP Backend to trigger notifications/broadcasts
app.post('/api/broadcast-booking', (req, res) => {
  const { event, booking_id, status, team_name } = req.body;
  
  if (!event) {
    return res.status(400).json({ error: 'Event name is required' });
  }

  console.log(`HTTP Broadcast trigger received from PHP Backend:`, req.body);

  // Broadcast to all clients (since this is triggered via HTTP curl, 
  // there is no "sender socket" to exclude from this specific broadcast, 
  // but any socket-based client triggers in io.on('connection') do exclude the sender).
  io.emit('booking_update', {
    type: event,
    booking_id: booking_id,
    status: status,
    team_name: team_name,
    message: `Booking #${booking_id} for ${team_name || 'Team'} is ${status}!`
  });

  return res.status(200).json({ success: true, message: 'Broadcast successful' });
});

// ============================================================
// FCM TOKEN MANAGEMENT (Modul 16 — Firebase Cloud Messaging)
// ============================================================

// In-memory FCM token store (keyed by user_id for demo)
// In production, this should be stored in MySQL database
const fcmTokens = new Map();

// Register/update FCM token from Flutter app
app.post('/api/register-fcm-token', (req, res) => {
  const { user_id, fcm_token } = req.body;

  if (!fcm_token) {
    return res.status(400).json({ error: 'FCM token is required' });
  }

  fcmTokens.set(String(user_id), fcm_token);
  console.log(`FCM Token registered for user ${user_id}: ${fcm_token.substring(0, 30)}...`);
  console.log(`Total registered FCM tokens: ${fcmTokens.size}`);

  return res.status(200).json({ 
    success: true, 
    message: 'FCM token registered successfully',
    total_tokens: fcmTokens.size
  });
});

// Send FCM push notification (triggered by PHP backend or admin action)
// Uses Firebase FCM HTTP v1 API format
app.post('/api/send-fcm', async (req, res) => {
  const { target_user_id, title, body, data } = req.body;

  if (!title || !body) {
    return res.status(400).json({ error: 'Title and body are required' });
  }

  // Get target token(s)
  let targetTokens = [];
  if (target_user_id) {
    const token = fcmTokens.get(String(target_user_id));
    if (token) targetTokens.push(token);
  } else {
    // Broadcast to all registered tokens
    targetTokens = Array.from(fcmTokens.values());
  }

  if (targetTokens.length === 0) {
    return res.status(404).json({ error: 'No FCM tokens found for target' });
  }

  console.log(`Sending FCM notification to ${targetTokens.length} device(s): "${title}"`);
  
  // Log the FCM payload (in production, you would use Firebase Admin SDK or HTTP v1 API)
  const fcmPayload = {
    notification: { title, body },
    data: data || {},
    tokens: targetTokens
  };
  console.log('FCM Payload:', JSON.stringify(fcmPayload, null, 2));

  // NOTE: To actually send via FCM HTTP v1 API, you need:
  // 1. A service-account.json from Firebase Console
  // 2. OAuth2 access token generation
  // 3. POST to https://fcm.googleapis.com/v1/projects/{project_id}/messages:send
  // For this demo, we simulate the send and also broadcast via Socket.IO

  // Simultaneously broadcast via Socket.IO for instant delivery
  io.emit('booking_update', {
    type: 'fcm_notification',
    message: body,
    title: title,
    data: data || {}
  });

  return res.status(200).json({ 
    success: true, 
    message: `FCM notification sent to ${targetTokens.length} device(s)`,
    payload: fcmPayload
  });
});

// List all registered FCM tokens (debug endpoint)
app.get('/api/fcm-tokens', (req, res) => {
  const tokens = {};
  fcmTokens.forEach((value, key) => {
    tokens[key] = value.substring(0, 30) + '...';
  });
  return res.status(200).json({ total: fcmTokens.size, tokens });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`WebSocket server is running on http://localhost:${PORT}`);
});
