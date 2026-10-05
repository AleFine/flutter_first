/// Curso matriculado con sus tres notas de la unidad.
class Curso {
  const Curso({
    required this.id,
    required this.nombre,
    required this.docente,
    required this.notaEl,
    required this.notaEt,
    required this.notaPt,
  });

  final String id;
  final String nombre;
  final String docente;
  final double notaEl;
  final double notaEt;
  final double notaPt;

  static const notaAprobatoria = 10.5;

  /// PU = (2·EL + ET + 2·PT) / 5, la fórmula del sílabo.
  static double calcularPromedio(double el, double et, double pt) =>
      (2 * el + et + 2 * pt) / 5;

  double get promedio => calcularPromedio(notaEl, notaEt, notaPt);

  bool get aprobado => promedio >= notaAprobatoria;

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'docente': docente,
    'nota_el': notaEl,
    'nota_et': notaEt,
    'nota_pt': notaPt,
  };

  factory Curso.fromMap(Map<String, dynamic> map) => Curso(
    id: map['id'] as String,
    nombre: map['nombre'] as String,
    docente: map['docente'] as String,
    notaEl: (map['nota_el'] as num).toDouble(),
    notaEt: (map['nota_et'] as num).toDouble(),
    notaPt: (map['nota_pt'] as num).toDouble(),
  );
}
