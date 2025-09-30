class AnnouncementsRepository {
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      {
        'id': 1,
        'titulo': 'Mantenimiento de Piscina',
        'contenido':
            'Se realizará mantenimiento de la piscina el día 25 de septiembre. La piscina estará cerrada de 8:00 AM a 2:00 PM.',
        'fecha': DateTime(2025, 9, 20),
        'leido': false,
      },
      {
        'id': 2,
        'titulo': 'Reunión de Propietarios',
        'contenido':
            'Se convoca a reunión ordinaria de propietarios para el día 30 de septiembre a las 18:00 en el salón de eventos.',
        'fecha': DateTime(2025, 9, 22),
        'leido': false,
      },
      {
        'id': 3,
        'titulo': 'Corte de Agua Programado',
        'contenido':
            'El día 28 de septiembre habrá corte de agua de 10:00 AM a 12:00 PM por trabajos de mantenimiento.',
        'fecha': DateTime(2025, 9, 25),
        'leido': true,
      },
    ];
  }

  Future<void> markAsRead(int announcementId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
