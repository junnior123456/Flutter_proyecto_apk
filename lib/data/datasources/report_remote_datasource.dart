import '../models/report_model.dart';
import 'http_service.dart';

abstract class ReportRemoteDataSource {
  Future<ReportModel> createReport(Map<String, dynamic> reportData);
  Future<List<ReportModel>> getReportsByUser(int userId);
  Future<List<ReportModel>> getAllReports({int? limit, int? offset, String? status});
  Future<ReportModel> updateReportStatus(int reportId, String status, {String? adminNotes});
  Future<void> deleteReport(int reportId);
  Future<Map<String, dynamic>> getReportStats();
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final HttpService httpService;
  
  ReportRemoteDataSourceImpl({required this.httpService});
  
  @override
  Future<ReportModel> createReport(Map<String, dynamic> reportData) async {
    try {
      final response = await httpService.post('/reports', body: reportData);
      
      if (response['success'] == true && response['data'] != null) {
        return ReportModel.fromJson(response['data']);
      } else {
        throw Exception('Failed to create report: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error creating report: ${e.toString()}');
    }
  }
  
  @override
  Future<List<ReportModel>> getReportsByUser(int userId) async {
    try {
      final response = await httpService.get('/reports/user/$userId');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> reportsJson = response['data'];
        return reportsJson.map((json) => ReportModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user reports: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error loading user reports: ${e.toString()}');
    }
  }
  
  @override
  Future<List<ReportModel>> getAllReports({int? limit, int? offset, String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (status != null) queryParams['status'] = status;
      
      final response = await httpService.get('/reports', queryParams: queryParams);
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> reportsJson = response['data'];
        return reportsJson.map((json) => ReportModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reports: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error loading reports: ${e.toString()}');
    }
  }
  
  @override
  Future<ReportModel> updateReportStatus(int reportId, String status, {String? adminNotes}) async {
    try {
      final body = <String, dynamic>{'status': status};
      if (adminNotes != null) {
        body['adminNotes'] = adminNotes;
      }
      
      final response = await httpService.put('/reports/$reportId/status', body: body);
      
      if (response['success'] == true && response['data'] != null) {
        return ReportModel.fromJson(response['data']);
      } else {
        throw Exception('Failed to update report status: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error updating report status: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteReport(int reportId) async {
    try {
      final response = await httpService.delete('/reports/$reportId');
      
      if (response['success'] != true) {
        throw Exception('Failed to delete report: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error deleting report: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getReportStats() async {
    try {
      final response = await httpService.get('/reports/stats');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load report stats: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error loading report stats: ${e.toString()}');
    }
  }
}