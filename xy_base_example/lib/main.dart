import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xy_base_library/base_response.dart';
import 'package:xy_base_library/dio_util.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DioUtil.openDebug();
  }

  void upload() async {
    try {
      String savePath = (await getExternalStorageDirectory()).path;
      String savePath1 = savePath.substring(0, savePath.indexOf("Android"));
      Map<String, dynamic> map = Map();
      map["driverId"] = 102;
      map["a"] = "aa";
      map["b"] = "bb";
      map["driverImg"] = await MultipartFile.fromFile(savePath1 + "photo.jpg");
      FormData formData = FormData.fromMap(map);
      BaseOptions options = DioUtil.getDefOptions();
      options.baseUrl = "https://yichuyou.my2715.biz/friendCarSystemAPI";
      HttpConfig config = HttpConfig(options: options);
      DioUtil().setConfig(config);
      BaseResponse baseResponse = await DioUtil.getInstance().request(
          Method.post, "/driverAppInterface/uploadDriverImg", data: formData,
          onSendProgress: (int count, int total) {
        print("上传进度：${count / total * 100} %");
      });
    } catch (e) {
      print(e);
    }
  }

  void getBanner() async {
    try {
      BaseOptions options = DioUtil.getDefOptions();
      options.baseUrl = "https://www.wanandroid.com/";
      HttpConfig config = HttpConfig(options: options);
      DioUtil().setConfig(config);
      BaseResponse<List> baseResp =
          await DioUtil.getInstance().request<List>(Method.get, "banner/json");
//      if (baseResp?.code != 0) {
//        return new Future.error(baseResp?.msg);
//      }
    } catch (e) {
      print("HTTP-ERROR:   " + e.toString());
    }
  }

  void downloadApk() async {
    String path =
        "https://c91adbf3bda2cd21cb3fc08da9099874.dd.cdntips.com/imtt.dd.qq.com/16891/6E581BFD4A633CE41ADEC642EEC336EB.apk?mkey=5e02f07275246acf&f=184b&fsname=com.gui.gui.chen.flash.light.one_2.3.5_235.apk&csr=1bbd&cip=117.36.76.58&proto=https";
    String savePath = (await getExternalStorageDirectory()).path;
    String savePath1 = savePath.substring(0, savePath.indexOf("Android"));
    String savePath2 = (await getApplicationDocumentsDirectory()).path;
//    String savePath3 = (await getApplicationSupportDirectory()).path;
    String savePath4 = (await getTemporaryDirectory()).path;
    String apkPath = savePath + "/TDF.apk";
    CancelToken cancelToken = CancelToken();
    try {
      Options options = Options();
      options.receiveTimeout = 9999999;
      await DioUtil.getInstance().download(path, apkPath,
          onProgress: (int count, int total) {
            print("下载进度：${count / total * 100} %");

//        if (count >= total / 10) {
//          cancelToken.cancel("cancelAll");
//        }
      }, options: options, cancelToken: cancelToken);
    } catch (e) {
      print("HTTP-ERROR:   " + (e as Exception).toString());
    }
  }

  void _incrementCounter() {
//    getBanner();
//    upload();
    downloadApk();
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
