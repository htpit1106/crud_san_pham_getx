import 'package:crud_getx_demo/core/error/failure.dart';
import 'package:crud_getx_demo/core/network/api_client.dart';
import 'package:crud_getx_demo/data/model/entities/token_entity.dart';
import 'package:crud_getx_demo/data/model/response/object_response.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, ObjectResponse<TokenEntity>>> login(
    String username,
    String password,
  );
}

class AuthRepositoryImpl extends AuthRepository {
  final ApiClient apiClient;
  AuthRepositoryImpl({required this.apiClient});
  @override
  Future<Either<Failure, ObjectResponse<TokenEntity>>> login(
    String username,
    String password,
  ) async {
    try {
      final result = await apiClient.login({
        "username": username,
        "password": password,
      });
      return Right(result);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
