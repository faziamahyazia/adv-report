<?php

use App\Http\Controllers\Admin\ActivityController;
use App\Http\Controllers\Admin\ActivityPlanController;
use App\Http\Controllers\Admin\ActivityPlanDetailController;
use App\Http\Controllers\Admin\ActivityTargetController;
use App\Http\Controllers\Admin\ActivityTypeController;
use App\Http\Controllers\Admin\AnalyticsController;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\CompanyProfileController;
use App\Http\Controllers\Admin\ComplaintController;
use App\Http\Controllers\Admin\CustomerController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\DatabaseController;
use App\Http\Controllers\Admin\DemoPlotController;
use App\Http\Controllers\Admin\DemoPlotVisitController;
use App\Http\Controllers\Admin\DistributorController;
use App\Http\Controllers\Admin\DistributorStockController;
use App\Http\Controllers\Admin\DistributorTargetController;
use App\Http\Controllers\Admin\HarvestResultController;
use App\Http\Controllers\Admin\InventoryLogController;
use App\Http\Controllers\Admin\NotificationController;
use App\Http\Controllers\Admin\ProductCategoryController;
use App\Http\Controllers\Admin\ProductController;
use App\Http\Controllers\Admin\ProductKnowledgeController;
use App\Http\Controllers\Admin\ProfileController;
use App\Http\Controllers\Admin\ReminderSettingController;
use App\Http\Controllers\Admin\ReportController;
use App\Http\Controllers\Admin\SaleController;
use App\Http\Controllers\Admin\TerritoryController;
use App\Http\Controllers\Admin\UserController;

use App\Http\Middleware\Auth;
use App\Http\Middleware\NonAuthenticated;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('admin.auth.login');
})->name('home');

Route::get('/test', function () {
    return inertia('Test');
})->name('test');

Route::get('/_cmd/clear-all-cache', function () {
    Artisan::call('config:clear');
    Artisan::call('cache:clear');
    Artisan::call('route:clear');
    Artisan::call('view:clear');
    Artisan::call('optimize:clear');
    return 'Cache cleared';
});

Route::middleware(NonAuthenticated::class)->group(function () {
    Route::prefix('/admin/auth')->group(function () {
        Route::match(['get', 'post'], 'login', [AuthController::class, 'login'])->name('admin.auth.login');
        Route::match(['get', 'post'], 'register', [AuthController::class, 'register'])->name('admin.auth.register');
        Route::match(['get', 'post'], 'forgot-password', [AuthController::class, 'forgotPassword'])->name('admin.auth.forgot-password');
    });
});

Route::middleware([Auth::class])->group(function () {
    Route::match(['get', 'post'], 'admin/auth/logout', [AuthController::class, 'logout'])->name('admin.auth.logout');

    Route::prefix('admin')->group(function () {
        Route::redirect('', 'admin/dashboard', 301);

        Route::get('dashboard', [DashboardController::class, 'index'])->name('admin.dashboard');
        Route::get('notifications/inbox', [NotificationController::class, 'inbox'])->name('admin.notification.inbox');
        Route::get('notifications/{id}/thread', [NotificationController::class, 'thread'])->name('admin.notification.thread');
        Route::post('notifications/read-all', [NotificationController::class, 'markAllAsRead'])->name('admin.notification.read-all');
        Route::post('notifications/{id}/read', [NotificationController::class, 'markAsRead'])->name('admin.notification.read');
        Route::post('notifications/{id}/reply', [NotificationController::class, 'reply'])->name('admin.notification.reply');
        Route::post('notifications/push-subscribe', [NotificationController::class, 'pushSubscribe'])->name('admin.notification.push-subscribe');

        Route::prefix('reports')->group(function () {
            Route::get('', [ReportController::class, 'index'])->name('admin.report.index');

            Route::get('demo-plot-detail', [ReportController::class, 'demoPlotDetail'])->name('admin.report.demo-plot-detail');
            Route::get('new-demo-plot-detail', [ReportController::class, 'newDemoPlotDetail'])->name('admin.report.new-demo-plot-detail');
            Route::get('demo-plot-with-photo', [ReportController::class, 'demoPlotWithPhoto'])->name('admin.report.demo-plot-with-photo');
            Route::get('client-actual-inventory', [ReportController::class, 'clientActualInventory'])->name('admin.report.client-actual-inventory');
            Route::get('activity-plan-detail', [ReportController::class, 'activityPlanDetail'])->name('admin.report.activity-plan-detail');
            Route::get('activity-realization-detail', [ReportController::class, 'activityRealizationDetail'])->name('admin.report.activity-realization-detail');
            Route::get('activity-target-detail', [ReportController::class, 'activiyTargetDetail'])->name('admin.report.activity-target-detail');
            Route::get('distributor-target-detail', [ReportController::class, 'distributorTargetDetail'])->name('admin.report.distributor-target-detail');
        });

        Route::middleware('auto-permission')->group(function () {
            Route::prefix('products')->group(function () {
                Route::get('', [ProductController::class, 'index'])->name('admin.product.index');
                Route::get('data', [ProductController::class, 'data'])->name('admin.product.data');
                Route::get('add', [ProductController::class, 'editor'])->name('admin.product.add');
                Route::get('duplicate/{id}', [ProductController::class, 'duplicate'])->name('admin.product.duplicate');
                Route::get('edit/{id}', [ProductController::class, 'editor'])->name('admin.product.edit');
                Route::post('save', [ProductController::class, 'save'])->name('admin.product.save');
                Route::post('delete/{id}', [ProductController::class, 'delete'])->name('admin.product.delete');
                Route::get('detail/{id}', [ProductController::class, 'detail'])->name('admin.product.detail');
                Route::get('export', [ProductController::class, 'export'])->name('admin.product.export');
            });

            Route::prefix('product-categories')->group(function () {
                Route::get('', [ProductCategoryController::class, 'index'])->name('admin.product-category.index');
                Route::get('data', [ProductCategoryController::class, 'data'])->name('admin.product-category.data');
                Route::get('add', [ProductCategoryController::class, 'editor'])->name('admin.product-category.add');
                Route::get('duplicate/{id}', [ProductCategoryController::class, 'duplicate'])->name('admin.product-category.duplicate');
                Route::get('edit/{id}', [ProductCategoryController::class, 'editor'])->name('admin.product-category.edit');
                Route::post('save', [ProductCategoryController::class, 'save'])->name('admin.product-category.save');
                Route::post('delete/{id}', [ProductCategoryController::class, 'delete'])->name('admin.product-category.delete');
            });

            Route::prefix('product-knowledge')->group(function () {
                Route::get('', [ProductKnowledgeController::class, 'index'])->name('admin.product-knowledge.index');
                Route::get('data', [ProductKnowledgeController::class, 'data'])->name('admin.product-knowledge.data');
                Route::get('harvest-data', [ProductKnowledgeController::class, 'harvestData'])->name('admin.product-knowledge.harvest-data');
                Route::post('harvest-store', [ProductKnowledgeController::class, 'harvestStore'])->name('admin.product-knowledge.harvest-store');
                Route::get('{id}/gallery', [ProductKnowledgeController::class, 'gallery'])->name('admin.product-knowledge.gallery');
                Route::get('{id}/photo-editor', [ProductKnowledgeController::class, 'photoEditor'])->name('admin.product-knowledge.photo-editor');
                Route::post('{id}/photo-save', [ProductKnowledgeController::class, 'photoSave'])->name('admin.product-knowledge.photo-save');
                Route::post('{id}/set-thumbnail/{photoId}', [ProductKnowledgeController::class, 'setThumbnail'])->name('admin.product-knowledge.set-thumbnail');
                Route::post('photo-delete/{photoId}', [ProductKnowledgeController::class, 'photoDelete'])->name('admin.product-knowledge.photo-delete');
            });

            Route::prefix('harvest-result')->group(function () {
                Route::get('', [HarvestResultController::class, 'index'])->name('admin.harvest-result.index');
                Route::post('', [HarvestResultController::class, 'store'])->name('admin.harvest-result.store');
                Route::post('update/{id}', [HarvestResultController::class, 'update'])->name('admin.harvest-result.update');
                Route::get('export-pdf/{id}', [HarvestResultController::class, 'exportPdf'])->name('admin.harvest-result.export-pdf');
                Route::post('delete-photo/{id}/{photoId}', [HarvestResultController::class, 'deletePhoto'])->name('admin.harvest-result.photo.delete');
                Route::post('delete-legacy-photo/{id}', [HarvestResultController::class, 'deleteLegacyPhoto'])->name('admin.harvest-result.photo.delete-legacy');
                Route::post('delete/{id}', [HarvestResultController::class, 'delete'])->name('admin.harvest-result.delete');
            });

            Route::prefix('customers')->group(function () {
                Route::get('', [CustomerController::class, 'index'])->name('admin.customer.index');
                Route::get('data', [CustomerController::class, 'data'])->name('admin.customer.data');
                Route::get('add', [CustomerController::class, 'editor'])->name('admin.customer.add');
                Route::get('duplicate/{id}', [CustomerController::class, 'duplicate'])->name('admin.customer.duplicate');
                Route::get('edit/{id}', [CustomerController::class, 'editor'])->name('admin.customer.edit');
                Route::post('save', [CustomerController::class, 'save'])->name('admin.customer.save');
                Route::post('delete/{id}', [CustomerController::class, 'delete'])->name('admin.customer.delete');
                Route::get('detail/{id}', [CustomerController::class, 'detail'])->name('admin.customer.detail');
                Route::get('export', [CustomerController::class, 'export'])->name('admin.customer.export');
            });

            Route::prefix('activity-types')->group(function () {
                Route::get('', [ActivityTypeController::class, 'index'])->name('admin.activity-type.index');
                Route::get('data', [ActivityTypeController::class, 'data'])->name('admin.activity-type.data');
                Route::get('add', [ActivityTypeController::class, 'editor'])->name('admin.activity-type.add');
                Route::get('duplicate/{id}', [ActivityTypeController::class, 'duplicate'])->name('admin.activity-type.duplicate');
                Route::get('edit/{id}', [ActivityTypeController::class, 'editor'])->name('admin.activity-type.edit');
                Route::post('save', [ActivityTypeController::class, 'save'])->name('admin.activity-type.save');
                Route::post('delete/{id}', [ActivityTypeController::class, 'delete'])->name('admin.activity-type.delete');
            });

            Route::prefix('activities')->group(function () {
                Route::get('', [ActivityController::class, 'index'])->name('admin.activity.index');
                Route::get('data', [ActivityController::class, 'data'])->name('admin.activity.data');
                Route::get('duplicate/{id}', [ActivityController::class, 'duplicate'])->name('admin.activity.duplicate');
                Route::get('add', [ActivityController::class, 'editor'])->name('admin.activity.add');
                Route::get('edit/{id}', [ActivityController::class, 'editor'])->name('admin.activity.edit');
                Route::get('detail/{id}', [ActivityController::class, 'detail'])->name('admin.activity.detail');
                Route::post('respond/{id}', [ActivityController::class, 'respond'])->name('admin.activity.respond');
                Route::post('save', [ActivityController::class, 'save'])->name('admin.activity.save');
                Route::post('delete/{id}', [ActivityController::class, 'delete'])->name('admin.activity.delete');
                Route::get('export', [ActivityController::class, 'export'])->name('admin.activity.export');
            });

            Route::prefix('activity-plans')->group(function () {
                Route::get('', [ActivityPlanController::class, 'index'])->name('admin.activity-plan.index');
                Route::get('data', [ActivityPlanController::class, 'data'])->name('admin.activity-plan.data');
                Route::get('duplicate/{id}', [ActivityPlanController::class, 'duplicate'])->name('admin.activity-plan.duplicate');
                Route::get('add', [ActivityPlanController::class, 'editor'])->name('admin.activity-plan.add');
                Route::get('edit/{id}', [ActivityPlanController::class, 'editor'])->name('admin.activity-plan.edit');
                Route::get('detail/{id}', [ActivityPlanController::class, 'detail'])->name('admin.activity-plan.detail');
                Route::post('respond/{id}', [ActivityPlanController::class, 'respond'])->name('admin.activity-plan.respond');
                Route::post('save', [ActivityPlanController::class, 'save'])->name('admin.activity-plan.save');
                Route::post('delete/{id}', [ActivityPlanController::class, 'delete'])->name('admin.activity-plan.delete');
                Route::get('export', [ActivityPlanController::class, 'export'])->name('admin.activity-plan.export');
            });

            Route::prefix('activity-plan-details')->group(function () {
                Route::get('', [ActivityPlanDetailController::class, 'index'])->name('admin.activity-plan-detail.index');
                Route::get('data', [ActivityPlanDetailController::class, 'data'])->name('admin.activity-plan-detail.data');
                Route::get('add', [ActivityPlanDetailController::class, 'editor'])->name('admin.activity-plan-detail.add');
                Route::get('edit/{id}', [ActivityPlanDetailController::class, 'editor'])->name('admin.activity-plan-detail.edit');
                Route::post('save', [ActivityPlanDetailController::class, 'save'])->name('admin.activity-plan-detail.save');
                Route::post('delete/{id}', [ActivityPlanDetailController::class, 'delete'])->name('admin.activity-plan-detail.delete');
            });


            Route::prefix('activity-targets')->group(function () {
                Route::get('', [ActivityTargetController::class, 'index'])->name('admin.activity-target.index');
                Route::get('data', [ActivityTargetController::class, 'data'])->name('admin.activity-target.data');
                Route::get('duplicate/{id}', [ActivityTargetController::class, 'duplicate'])->name('admin.activity-target.duplicate');
                Route::get('add', [ActivityTargetController::class, 'editor'])->name('admin.activity-target.add');
                Route::get('edit/{id}', [ActivityTargetController::class, 'editor'])->name('admin.activity-target.edit');
                Route::get('detail/{id}', [ActivityTargetController::class, 'detail'])->name('admin.activity-target.detail');
                Route::post('save', [ActivityTargetController::class, 'save'])->name('admin.activity-target.save');
                Route::post('delete/{id}', [ActivityTargetController::class, 'delete'])->name('admin.activity-target.delete');
                Route::get('export', [ActivityTargetController::class, 'export'])->name('admin.activity-target.export');
            });

            Route::prefix('demo-plots')->group(function () {
                Route::get('', [DemoPlotController::class, 'index'])->name('admin.demo-plot.index');
                Route::get('data', [DemoPlotController::class, 'data'])->name('admin.demo-plot.data');
                Route::get('export', [DemoPlotController::class, 'export'])->name('admin.demo-plot.export');
                Route::get('detail/{id}', [DemoPlotController::class, 'detail'])->name('admin.demo-plot.detail');
                Route::get('duplicate/{id}', [DemoPlotController::class, 'duplicate'])->name('admin.demo-plot.duplicate');
                Route::get('add', [DemoPlotController::class, 'editor'])->name('admin.demo-plot.add');
                Route::get('edit/{id}', [DemoPlotController::class, 'editor'])->name('admin.demo-plot.edit');
                Route::post('save', [DemoPlotController::class, 'save'])->name('admin.demo-plot.save');
                Route::post('delete/{id}', [DemoPlotController::class, 'delete'])->name('admin.demo-plot.delete');
            });

            Route::prefix('demo-plot-vistis')->group(function () {
                Route::get('', [DemoPlotVisitController::class, 'index'])->name('admin.demo-plot-visit.index');
                Route::get('data', [DemoPlotVisitController::class, 'data'])->name('admin.demo-plot-visit.data');
                Route::get('detail/{id}', [DemoPlotVisitController::class, 'detail'])->name('admin.demo-plot-visit.detail');
                Route::get('export', [DemoPlotVisitController::class, 'export'])->name('admin.demo-plot-visit.export');
                Route::get('add', [DemoPlotVisitController::class, 'editor'])->name('admin.demo-plot-visit.add');
                Route::get('edit/{id}', [DemoPlotVisitController::class, 'editor'])->name('admin.demo-plot-visit.edit');
                Route::post('save', [DemoPlotVisitController::class, 'save'])->name('admin.demo-plot-visit.save');
                Route::post('delete/{id}', [DemoPlotVisitController::class, 'delete'])->name('admin.demo-plot-visit.delete');
            });

            Route::prefix('inventory-logs')->group(function () {
                Route::get('', [InventoryLogController::class, 'index'])->name('admin.inventory-log.index');
                Route::get('data', [InventoryLogController::class, 'data'])->name('admin.inventory-log.data');
                Route::get('add', [InventoryLogController::class, 'editor'])->name('admin.inventory-log.add');
                // Route::get('duplicate/{id}', [InventoryLogController::class, 'duplicate'])->name('admin.inventory-log.duplicate');
                Route::get('edit/{id}', [InventoryLogController::class, 'editor'])->name('admin.inventory-log.edit');
                Route::post('save', [InventoryLogController::class, 'save'])->name('admin.inventory-log.save');
                Route::post('delete/{id}', [InventoryLogController::class, 'delete'])->name('admin.inventory-log.delete');
                Route::post('delete-all', [InventoryLogController::class, 'deleteAll'])->name('admin.inventory-log.delete-all');
                Route::get('detail/{id}', [InventoryLogController::class, 'detail'])->name('admin.inventory-log.detail');
                Route::get('export', [InventoryLogController::class, 'export'])->name('admin.inventory-log.export');
            });

            Route::prefix('complaints')->group(function () {
                Route::get('', [ComplaintController::class, 'index'])->name('admin.complaint.index');
                Route::get('data', [ComplaintController::class, 'data'])->name('admin.complaint.data');
                Route::get('analytics', [ComplaintController::class, 'analytics'])->name('admin.complaint.analytics');
                Route::get('analytics-data', [ComplaintController::class, 'analyticsData'])->name('admin.complaint.analytics-data');
                Route::get('map-data', [ComplaintController::class, 'mapData'])->name('admin.complaint.map-data');
                Route::get('export', [ComplaintController::class, 'export'])->name('admin.complaint.export');
                Route::get('add', [ComplaintController::class, 'editor'])->name('admin.complaint.add');
                Route::get('edit/{id}', [ComplaintController::class, 'editor'])->name('admin.complaint.edit');
                Route::post('save', [ComplaintController::class, 'save'])->name('admin.complaint.save');
                Route::post('respond/{id}', [ComplaintController::class, 'respond'])->name('admin.complaint.respond');
                Route::post('delete/{id}', [ComplaintController::class, 'delete'])->name('admin.complaint.delete');
                Route::get('detail/{id}', [ComplaintController::class, 'detail'])->name('admin.complaint.detail');
            });

            // ── Territory API ──────────────────────────────────────────
            Route::prefix('territory')->group(function () {
                Route::get('provinces', [TerritoryController::class, 'provinces'])->name('admin.territory.api.provinces');
                Route::get('provinces/{id}/districts', [TerritoryController::class, 'districts'])->name('admin.territory.api.districts');
                Route::get('districts/{id}/villages', [TerritoryController::class, 'villages'])->name('admin.territory.api.villages');
            });

            // ── Sales ──────────────────────────────────────────────────
            Route::prefix('sales')->group(function () {
                Route::get('', [SaleController::class, 'index'])->name('admin.sale.index');
                Route::get('data', [SaleController::class, 'data'])->name('admin.sale.data');
                Route::get('distributor-stocks', [SaleController::class, 'distributorStocks'])->name('admin.sale.distributor-stocks');
                Route::get('distributor-detail', [SaleController::class, 'distributorDetail'])->name('admin.sale.distributor-detail');
                Route::get('add', [SaleController::class, 'add'])->name('admin.sale.add');
                Route::get('export', [SaleController::class, 'export'])->name('admin.sale.export');
                Route::get('import-template', [SaleController::class, 'importTemplate'])->name('admin.sale.import-template');
                Route::post('import', [SaleController::class, 'import'])->name('admin.sale.import');
                Route::post('save', [SaleController::class, 'save'])->name('admin.sale.save');
                Route::get('{id}/release-data', [SaleController::class, 'releaseData'])->name('admin.sale.release-data');
                Route::post('{id}/release', [SaleController::class, 'release'])->name('admin.sale.release');
                Route::get('{id}/edit', [SaleController::class, 'edit'])->name('admin.sale.edit');
                Route::post('{id}/delete', [SaleController::class, 'delete'])->name('admin.sale.delete');
                Route::get('{id}', [SaleController::class, 'detail'])->name('admin.sale.detail');
            });

            // ── Distributors ───────────────────────────────────────────
            Route::prefix('distributors')->group(function () {
                Route::get('', [DistributorController::class, 'index'])->name('admin.distributor.index');
                Route::get('data', [DistributorController::class, 'data'])->name('admin.distributor.data');
                Route::get('{id}', [DistributorController::class, 'detail'])->name('admin.distributor.detail');
            });

            // ── Distributor Stock ──────────────────────────────────────
            Route::prefix('distributor-stocks')->group(function () {
                Route::get('', [DistributorStockController::class, 'index'])->name('admin.distributor-stock.index');
                Route::get('data', [DistributorStockController::class, 'data'])->name('admin.distributor-stock.data');
                Route::get('add', [DistributorStockController::class, 'add'])->name('admin.distributor-stock.add');
                Route::post('save', [DistributorStockController::class, 'save'])->name('admin.distributor-stock.save');
                Route::post('adjust', [DistributorStockController::class, 'adjust'])->name('admin.distributor-stock.adjust');
                Route::post('delete', [DistributorStockController::class, 'delete'])->name('admin.distributor-stock.delete');
                Route::get('{id}/movements', [DistributorStockController::class, 'movements'])->name('admin.distributor-stock.movements');
                Route::get('{id}/movements/data', [DistributorStockController::class, 'movementsData'])->name('admin.distributor-stock.movements.data');
            });

            // ── Distributor Target ─────────────────────────────────────
            Route::prefix('distributor-targets')->group(function () {
                Route::get('', [DistributorTargetController::class, 'index'])->name('admin.distributor-target.index');
                Route::get('data', [DistributorTargetController::class, 'data'])->name('admin.distributor-target.data');
                Route::get('export', [DistributorTargetController::class, 'export'])->name('admin.distributor-target.export');
                Route::get('add', [DistributorTargetController::class, 'editor'])->name('admin.distributor-target.add');
                Route::get('edit/{id}', [DistributorTargetController::class, 'editor'])->name('admin.distributor-target.edit');
                Route::post('save', [DistributorTargetController::class, 'save'])->name('admin.distributor-target.save');
                Route::post('delete/{id}', [DistributorTargetController::class, 'delete'])->name('admin.distributor-target.delete');
                Route::post('import', [DistributorTargetController::class, 'import'])->name('admin.distributor-target.import');
            });

            // ── Analytics ─────────────────────────────────────────────
            Route::prefix('analytics')->group(function () {
                Route::get('', [AnalyticsController::class, 'index'])->name('admin.analytics.index');
                Route::get('sales-chart', [AnalyticsController::class, 'salesChart'])->name('admin.analytics.sales-chart');
            });
        });

        Route::prefix('settings')->group(function () {
            Route::get('profile/edit', [ProfileController::class, 'edit'])->name('admin.profile.edit');
            Route::post('profile/update', [ProfileController::class, 'update'])->name('admin.profile.update');
            Route::post('profile/update-password', [ProfileController::class, 'updatePassword'])->name('admin.profile.update-password');

            Route::get('company-profile/edit', [CompanyProfileController::class, 'edit'])->name('admin.company-profile.edit');
            Route::post('company-profile/update', [CompanyProfileController::class, 'update'])->name('admin.company-profile.update');

            Route::get('reminders/wa', [ReminderSettingController::class, 'edit'])->name('admin.reminder.edit');
            Route::post('reminders/wa', [ReminderSettingController::class, 'update'])->name('admin.reminder.update');
            Route::post('reminders/wa/trigger-weekly', [ReminderSettingController::class, 'triggerWeekly'])->name('admin.reminder.trigger-weekly');
            Route::post('reminders/wa/trigger-plan', [ReminderSettingController::class, 'triggerPlan'])->name('admin.reminder.trigger-plan');
            Route::post('reminders/wa/trigger-report', [ReminderSettingController::class, 'triggerReport'])->name('admin.reminder.trigger-report');
            Route::get('notifications/info', [NotificationController::class, 'index'])->name('admin.notification.index');
            Route::post('notifications/info', [NotificationController::class, 'store'])->name('admin.notification.store');

            Route::prefix('users')->middleware(['auto-permission'])->group(function () {
                Route::get('', [UserController::class, 'index'])->name('admin.user.index');
                Route::get('data', [UserController::class, 'data'])->name('admin.user.data');
                Route::get('add', [UserController::class, 'editor'])->name('admin.user.add');
                Route::get('edit/{id}', [UserController::class, 'editor'])->name('admin.user.edit');
                Route::get('duplicate/{id}', [UserController::class, 'duplicate'])->name('admin.user.duplicate');
                Route::post('save', [UserController::class, 'save'])->name('admin.user.save');
                Route::post('delete/{id}', [UserController::class, 'delete'])->name('admin.user.delete');
                Route::get('detail/{id}', [UserController::class, 'detail'])->name('admin.user.detail');
                Route::get('export', [UserController::class, 'export'])->name('admin.user.export');
            });

            Route::get('database', [DatabaseController::class, 'index'])->name('admin.db.index');
            Route::get('database/backup', [DatabaseController::class, 'backup'])->name('admin.db.backup');
            Route::get('db/restore', [DatabaseController::class, 'restore'])->name('admin.db.restore');
            Route::post('database/audit-files', [DatabaseController::class, 'auditFiles'])->name('admin.db.audit-files');
            Route::post('database/audit-db', [DatabaseController::class, 'auditDb'])->name('admin.db.audit-db');
            Route::post('database/cleanup', [DatabaseController::class, 'cleanup'])->name('admin.db.cleanup');
        });
    });
});
