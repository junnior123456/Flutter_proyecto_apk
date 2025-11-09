import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';
import '../models/report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  
  ReportRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Report> createReport(Report report) async {
    try {
      final reportData = ReportModel.fromEntity(report).toCreateJson();
      final reportModel = await remoteDataSource.createReport(reportData);
      return reportModel.toEntity();
    } catch (e) {
      throw Exception('Failed to create report: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Report>> getReportsByUser(int userId) async {
    try {
      final reportModels = await remoteDataSource.getReportsByUser(userId);
      return reportModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get reports by user: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Report>> getAllReports({int? limit, int? offset, ReportStatus? status}) async {
    try {
      final reportModels = await remoteDataSource.getAllReports(
        limit: limit, 
        offset: offset, 
        status: status?.name
      );
      return reportModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get all reports: ${e.toString()}');
    }
  }
  
  @override
  Future<Report> updateReportStatus(int reportId, ReportStatus status, {String? adminNotes}) async {
    try {
      final reportModel = await remoteDataSource.updateReportStatus(reportId, status.name, adminNotes: adminNotes);
      return reportModel.toEntity();
    } catch (e) {
      throw Exception('Failed to update report status: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteReport(int reportId) async {
    try {
      await remoteDataSource.deleteReport(reportId);
    } catch (e) {
      throw Exception('Failed to delete report: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getReportStats() async {
    try {
      return await remoteDataSource.getReportStats();
    } catch (e) {
      throw Exception('Failed to get report stats: ${e.toString()}');
    }
  }
}