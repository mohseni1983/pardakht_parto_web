import 'dart:convert';
import 'package:pardakht_parto/classes/global_variables.dart' as globalVars;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkAuth() async{
  SharedPreferences _prefs=await SharedPreferences.getInstance();
  if(!_prefs.containsKey('time'))
    return false;
  String _expTimeStr=_prefs.getString('time');
  DateTime _expTime=DateTime.parse(_expTimeStr);
  if(_expTime.isBefore(DateTime.now()))
    {
      String _username=_prefs.getString('username');
      String _password=_prefs.getString('device_id');
      var _tokenResult=await http.post(Uri.parse('${globalVars.srvUrl}/Api/Charge/Login'),
        body: {
          'username':'$_username',
          'password':'$_password',
          'grant_type':'password'
        },);
      if(_tokenResult.statusCode==200){
        var tres=json.decode(_tokenResult.body);

        _prefs.setString('token', tres['access_token']);
        String _expTimes=DateTime.now().add(Duration(seconds:tres['expires_in'] )).toString();
        _prefs.setString('time',_expTimes );
        _prefs.setString('refresh_token', tres['refresh_token']);
      }
      else
        return false;
    }
  return true;
}

Future<void> retryAuth() async{
  SharedPreferences _prefs=await SharedPreferences.getInstance();


    String _username=_prefs.getString('username');
    String _password=_prefs.getString('device_id');
    var _tokenResult=await http.post(Uri.parse('${globalVars.srvUrl}/Api/Charge/Login'),
      body: {
        'username':'$_username',
        'password':'$_password',
        'grant_type':'password'
      },);
    if(_tokenResult.statusCode==200){
      var tres=json.decode(_tokenResult.body);

      _prefs.setString('token', tres['access_token']);
      String _expTimes=DateTime.now().add(Duration(seconds:tres['expires_in'] )).toString();
      _prefs.setString('time',_expTimes );
      _prefs.setString('refresh_token', tres['refresh_token']);
    }

}





/*
 if(_prefs.containsKey('username') && _prefs.containsKey('device_id'))
    {
      String _username=_prefs.getString('username');
      String _password=_prefs.getString('device_id');
      var token_result=await http.post('${globalVars.srvUrl}/Api/Charge/Login',
          body: {
          'username':'$_username',
          'password':'$_password',
          'grant_type':'password'
          },);
      if(token_result.statusCode==200){

      }

      }
 */