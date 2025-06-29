enum MessageSender { user, bot }

class Message {
  final String text;
  final MessageSender sender;

  Message(this.text, this.sender);
}
