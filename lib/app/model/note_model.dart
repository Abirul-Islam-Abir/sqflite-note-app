class Note {
  int id;
  String title;
  String content;
  Note({required this.id, required this.title, required this.content});
  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'content': content};
  }

  factory Note.fromMap(Map<String, dynamic> json) =>
      Note(id: json['id'], title: json['title'], content: json['content']);
}