<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Symfony\Component\Process\Process;
use Symfony\Component\Process\Exception\ProcessFailedException;

class DatabaseController extends Controller
{
    public function index()
    {
        return inertia('admin/database/Index', [
            'defaults' => [
                'app_path' => base_path(),
                'backup_path' => '/root/deploy-backups',
                'log_retention_days' => 14,
                'backup_retention_days' => 30,
                'large_file_size_mb' => 100,
                'db_name' => env('DB_DATABASE', ''),
            ],
        ]);
    }

    public function backup()
    {
        $database = env('DB_DATABASE');
        $username = env('DB_USERNAME');
        $password = env('DB_PASSWORD');
        $host = env('DB_HOST');

        // Pastikan path mysqldump tersedia di PATH atau berikan path lengkap
        $command = "mysqldump --user={$username} --password={$password} --host={$host} {$database} > " . storage_path('app/backup.sql');

        try {
            $process = Process::fromShellCommandline($command);
            $process->setTimeout(3600); // Set timeout for large databases
            $process->run();

            if (!$process->isSuccessful()) {
                throw new ProcessFailedException($process);
            }

            return response()->download(storage_path('app/backup.sql'))->deleteFileAfterSend(true);
        } catch (ProcessFailedException $exception) {
            // Handle error, e.g., log it or return an error response
            return back()->with('error', 'Gagal membuat backup: ' . $exception->getMessage());
        }
    }

    public function restore() {}

    public function auditFiles(Request $request)
    {
        $this->ensureAdmin($request);

        $payload = $this->runManageScript('audit', [], [
            'APP_PATH' => $request->input('app_path', base_path()),
            'BACKUP_PATH' => $request->input('backup_path', '/root/deploy-backups'),
            'LARGE_FILE_SIZE_MB' => (string) $request->input('large_file_size_mb', 100),
        ]);

        return response()->json($payload);
    }

    public function auditDb(Request $request)
    {
        $this->ensureAdmin($request);

        $dbName = (string) $request->input('db_name', env('DB_DATABASE', ''));
        if ($dbName === '') {
            return response()->json([
                'ok' => false,
                'message' => 'Nama database wajib diisi.',
            ], 422);
        }

        $payload = $this->runManageScript('db-audit', [], [
            'DB_HOST' => env('DB_HOST', '127.0.0.1'),
            'DB_PORT' => (string) env('DB_PORT', '3306'),
            'DB_USER' => env('DB_USERNAME', 'root'),
            'DB_PASS' => env('DB_PASSWORD', ''),
            'DB_NAME' => $dbName,
        ]);

        return response()->json($payload);
    }

    public function cleanup(Request $request)
    {
        $this->ensureAdmin($request);

        $apply = (bool) $request->boolean('apply', false);
        $args = $apply ? ['--apply'] : [];

        $payload = $this->runManageScript('cleanup', $args, [
            'APP_PATH' => $request->input('app_path', base_path()),
            'BACKUP_PATH' => $request->input('backup_path', '/root/deploy-backups'),
            'LOG_RETENTION_DAYS' => (string) $request->input('log_retention_days', 14),
            'BACKUP_RETENTION_DAYS' => (string) $request->input('backup_retention_days', 30),
        ]);

        return response()->json($payload);
    }

    private function ensureAdmin(Request $request): void
    {
        if ($request->user()->role !== User::Role_Admin) {
            abort(403, 'Akses ditolak. Hanya administrator yang diizinkan.');
        }
    }

    private function runManageScript(string $subCommand, array $args = [], array $env = []): array
    {
        $scriptPath = base_path('manage-vps.sh');
        if (!file_exists($scriptPath)) {
            return [
                'ok' => false,
                'message' => 'Script manage-vps.sh tidak ditemukan di root aplikasi.',
                'output' => '',
                'exit_code' => 1,
            ];
        }

        $command = array_merge(['bash', $scriptPath, $subCommand], $args);
        $process = new Process($command, base_path(), array_merge($_ENV, $env));
        $process->setTimeout(300);
        $process->run();

        $rawOutput = $process->getOutput() . "\n" . $process->getErrorOutput();
        $cleanOutput = preg_replace('/\e\[[\d;]*m/', '', $rawOutput) ?? $rawOutput;

        return [
            'ok' => $process->isSuccessful(),
            'message' => $process->isSuccessful() ? 'Perintah selesai.' : 'Perintah gagal dijalankan.',
            'output' => trim($cleanOutput),
            'exit_code' => $process->getExitCode() ?? 1,
        ];
    }
}
