import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uri/uri.dart';

class Donate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new DonateState();
}

class DonateState extends State<Donate> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: false);
    } else {
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text('Cannot launch browser.'),
          duration: Duration(seconds: 2)
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new GestureDetector(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Icon(Icons.payment, size: 45.0, color: Colors.blue),
                  new Text('ALIPAY', style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.0
                  ))
                ],
              )
            ],
          ),
          onTap: () {
            UriTemplate template = new UriTemplate("alipayqr://platformapi/startapp?saId={id}&clientVersion={version}&qrcode={code}");
            String uri = template.expand({'id':'10000007', 'version':'3.7.0.0718', 'code':'https://qr.alipay.com/fkx05697d3efweuzsizkm82'});
            _launchUrl(uri);
          },
        )
    );
  }
}
