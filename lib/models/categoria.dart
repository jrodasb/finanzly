enum Categoria {
  comida('Comida', '🍔'),
  transporte('Transporte', '🚌'),
  entretenimiento('Entretenimiento', '🎬'),
  salud('Salud', '💊'),
  educacion('Educación', '📚'),
  hogar('Hogar', '🏠'),
  ropa('Ropa', '👕'),
  servicios('Servicios', '💡'),
  otros('Otros', '📦');

  final String label;
  final String icono;
  const Categoria(this.label, this.icono);
}
