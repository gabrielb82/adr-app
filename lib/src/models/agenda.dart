class Agenda {
  String classID;
  String className;
  int duration;
  String room;
  String status;
  bool studentFinish;
  bool teacherFinish;
  String teacherID;
  String teacherName;
  String name;
  String unitName;
  String dtAula;
  String horaIni;

  Agenda({
    this.classID,
    this.className,
    this.duration,
    this.room,
    this.status,
    this.studentFinish,
    this.teacherFinish,
    this.teacherID,
    this.teacherName,
    this.name,
    this.unitName,
    this.dtAula,
    this.horaIni,
  });

  factory Agenda.fromJson(Map<String, dynamic> json) {
    return Agenda(
      classID: json["id_aula"] ?? "",
      className: json["curso"] ?? "Música",
      room: json["num_sala"] ?? "-",
      status: json["status"] ?? "Prevista",
      studentFinish: false,
      teacherFinish: false,
      teacherID: json["chave_professor"] ?? "",
      teacherName: json["professor"] ?? "-",
      name: json["curso"] ?? "Música",
      dtAula: json["dt_aula"] ?? "2020-06-01",
      horaIni: json["hora_ini"] ?? "00:00:00",
      // unit_name: json[""],
    );
  }
}
