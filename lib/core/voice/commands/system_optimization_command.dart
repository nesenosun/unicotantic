
import '../action_command.dart';
import '../../optimization/antigravity_optimizer.dart';

/// Akış Projesi - Sistem Optimizasyonu Komutu
/// "Sistemi optimize et", "kaynakları temizle" gibi komutlarla tetiklenir.
class SystemOptimizationCommand extends ActionCommand {
  @override
  List<String> get triggers => [
        'optimize et',
        'sistemi hızlandır',
        'temizlik yap',
        'kaynakları boşalt',
        'sistemi rahatlat'
      ];

  @override
  void execute(dynamic arguments) {
    print("🚀 Komut Algılandı: Sistem Optimizasyonu");
    AntigravityOptimizer.optimizeResources();
    AntigravityOptimizer.auditPerformance();
  }
}
