# PowerWords

**PowerWords** is a lightweight World of Warcraft addon that sends a configurable message when you cast **Power Infusion**.

It’s designed to be fun, flexible, and unobtrusive — no automation, no combat decisions, just personality.

---

## ✨ Features

- 🔮 Sends a random message when you cast **Power Infusion**
- 🎯 Audience filtering:
  - Everyone
  - Guild members
  - Battle.net friends
  - Guild OR Battle.net friends
  - Whitelist
  - Blacklist
- 📝 Unlimited custom messages (one per line)
- 🧪 Built-in test button (no need to bother other players)
- 👤 Optional “Works on Self” mode for easy testing
- 🪶 Lightweight, no performance impact

---

## ⚙️ Configuration

Open the configuration window with:

`/pw` OR `/powerwords`

From there you can:
- Enable or disable the addon
- Choose who receives messages
- Manage whitelist / blacklist entries
- Edit and preview your message list
- Test messages without casting Power Infusion

---

## 🧪 Testing

- **Test** button: whispers yourself
- **Shift + Test**: whispers your current target
- Enable **“Works on Self”** to test by casting Power Infusion on yourself

All test actions bypass audience filtering.

---

## 💬 Message Behavior

- Messages are sent via **whisper**
- One random message is selected per cast
- No messages are sent if:
  - The addon is disabled
  - The audience filter blocks the target
  - No messages are configured

---

## 🛡️ Notes & Compatibility

- Uses spellcast events (not combat log)
- Fully compliant with Blizzard addon policies
- No automation or gameplay decision-making
- Designed for **Retail WoW**

---

## 📜 License

MIT License — feel free to modify, fork, or contribute.

---