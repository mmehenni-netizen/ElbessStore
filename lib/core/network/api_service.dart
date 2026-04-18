import 'package:dio/dio.dart';
import 'package:elbess_store/core/network/api_exception.dart';
import 'package:elbess_store/core/network/dio_client.dart';

class ApiService {
  final DioClient _dioClient=DioClient();

Future<dynamic> get(String endpoint, {required Map<String, String> queryParameters})async{
 try{
 final response=await _dioClient.dio.get(endpoint);
  return response.data;
  

 }on DioException catch (e){
 return ApiException.handleError(e);
 }
}



Future<dynamic> post(String endpoint, Map<dynamic,String> body)async{
 try{
 final response=await _dioClient.dio.post(endpoint,data : body);
  return response.data;
  

 }on DioException catch (e){
 return ApiException.handleError(e);
 }
}



Future<dynamic> postMultipart(String endpoint, FormData body) async {
 try {
  final response = await _dioClient.dio.post(endpoint, data: body);
  return response.data;

 } on DioException catch (e) {
  return ApiException.handleError(e);
 }
}


Future<dynamic> put(String endpoint, Map<dynamic,String> body)async{
 try{
 final response=await _dioClient.dio.put(endpoint,data: body);
  return response.data;
  

 }on DioException catch (e){
 return ApiException.handleError(e);
 }
}


Future<dynamic> delete(String endpoint, Map<dynamic,String> body)async{
 try{
 final response=await _dioClient.dio.delete(endpoint,data: body);
  return response.data;
  

 }on DioException catch (e){
 return ApiException.handleError(e);
 }
}

}