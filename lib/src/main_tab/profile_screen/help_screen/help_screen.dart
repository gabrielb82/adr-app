import 'package:auto_size_text/auto_size_text.dart';
//import 'package:fancy_on_boarding/fancy_on_boarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // final pageList = [
  //   PageModel(
  //       //color: const Color(0xFF678FB4),
  //       color: Color(0xFFE46453),
  //       heroAssetPath: 'assets/images/news.png',
  //       title: Text('Novidades',
  //           style: TextStyle(
  //             fontWeight: FontWeight.w800,
  //             color: Colors.white,
  //             fontSize: 34.0,
  //           )),
  //       body: Padding(
  //         padding: const EdgeInsets.all(10.0),
  //         child: Text(
  //             'Acesse as novidades postadas pela escola em um painel exclusivo!',
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 18.0,
  //             )),
  //       ),
  //       iconAssetPath: 'assets/icons/icon_news.png'),
  //   PageModel(
  //       color: Color(0xFF1A1C20),
  //       heroAssetPath: 'assets/images/calendar.png',
  //       title: Padding(
  //         padding: const EdgeInsets.all(10.0),
  //         child: Text('Calendário',
  //             style: TextStyle(
  //               fontWeight: FontWeight.w800,
  //               color: Colors.white,
  //               fontSize: 34.0,
  //             )),
  //       ),
  //       body: Padding(
  //         padding: const EdgeInsets.all(10.0),
  //         child: Text(
  //             'Acompanhe o calendário das suas aulas, ensaios e práticas de banda marcadas!',
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 18.0,
  //             )),
  //       ),
  //       iconAssetPath: 'assets/icons/icon_calendar.png'),
  //   PageModel(
  //     color: Color(0xFFE46453),
  //     heroAssetPath: 'assets/images/checklist.png',
  //     title: AutoSizeText('Conteúdo das aulas',
  //         maxLines: 1,
  //         style: TextStyle(
  //           fontWeight: FontWeight.w800,
  //           color: Colors.white,
  //           fontSize: 34.0,
  //         )),
  //     body: Padding(
  //       padding: const EdgeInsets.all(10.0),
  //       child: Text(
  //           'Você pode também acompanhar o conteúdo que foi visto na sua aula.',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 18.0,
  //           )),
  //     ),
  //     iconAssetPath: 'assets/icons/icon_checklist.png',
  //   ),
  //   PageModel(
  //     color: Color(0xFF1A1C20),
  //     heroAssetPath: 'assets/images/speaking.png',
  //     title: AutoSizeText('Comentários',
  //         maxLines: 1,
  //         style: TextStyle(
  //           fontWeight: FontWeight.w800,
  //           color: Colors.white,
  //           fontSize: 34.0,
  //         )),
  //     body: Text(
  //         'Gostou da aula ou de alguma notícia? Agora você pode deixar um comentário e interagir com o pessoal da escola pelo celular!',
  //         textAlign: TextAlign.center,
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: 16.0,
  //         )),
  //     iconAssetPath: 'assets/icons/icon_comment.png',
  //   ),
  //   PageModel(
  //     color: Color(0xFFE46453),
  //     heroAssetPath: 'assets/images/metronome.png',
  //     title: AutoSizeText('Metrônomo',
  //         maxLines: 1,
  //         style: TextStyle(
  //           fontWeight: FontWeight.w800,
  //           color: Colors.white,
  //           fontSize: 34.0,
  //         )),
  //     body: Text(
  //         'Dê uma olhada nessa facilidade que trouxemos para você! Agora o app da Academia do Rock possui o seu exclusivo metrônomo para te ajudar nos seus estudos em casa.',
  //         textAlign: TextAlign.center,
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: 16.0,
  //         )),
  //     iconAssetPath: 'assets/icons/icon_metronome.png',
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: Container(),
      //Pass pageList and the mainPage route.
      // body: FancyOnBoarding(
      //   doneButtonText: "Entendi",
      //   skipButtonText: "Fechar",
      //   pageList: pageList,
      //   onDoneButtonPressed: () => Navigator.of(context).pop(),
      //   onSkipButtonPressed: () => Navigator.of(context).pop(),
      // ),
    );
  }
}
