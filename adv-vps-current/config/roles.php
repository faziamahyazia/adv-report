<?php

use App\Models\User;

return [
    User::Role_BS => [
        'admin.user.index',
        'admin.user.data',
        'admin.user.detail',
        'admin.user.export',

        'admin.product.index',
        'admin.product.data',
        'admin.product.detail',

        'admin.product-knowledge.index',
        'admin.product-knowledge.data',
        'admin.product-knowledge.harvest-data',
        'admin.product-knowledge.harvest-store',
        'admin.product-knowledge.gallery',

        'admin.harvest-result.index',
        'admin.harvest-result.store',

        'admin.demo-plot.index',
        'admin.demo-plot.data',
        'admin.demo-plot.detail',
        'admin.demo-plot.add',
        'admin.demo-plot.edit',
        'admin.demo-plot.save',
        'admin.demo-plot.duplicate',
        'admin.demo-plot.export',

        'admin.demo-plot-visit.index',
        'admin.demo-plot-visit.data',
        'admin.demo-plot-visit.detail',
        'admin.demo-plot-visit.add',
        'admin.demo-plot-visit.edit',
        'admin.demo-plot-visit.save',

        'admin.activity-plan.index',
        'admin.activity-plan.data',
        'admin.activity-plan.add',
        'admin.activity-plan.edit',
        'admin.activity-plan.save',
        'admin.activity-plan.delete',
        'admin.activity-plan.detail',

        'admin.activity-plan-detail.index',
        'admin.activity-plan-detail.data',
        'admin.activity-plan-detail.add',
        'admin.activity-plan-detail.edit',
        'admin.activity-plan-detail.save',
        'admin.activity-plan-detail.delete',

        'admin.activity.index',
        'admin.activity.data',
        'admin.activity.add',
        'admin.activity.edit',
        'admin.activity.save',
        'admin.activity.delete',
        'admin.activity.detail',

        'admin.customer.index',
        'admin.customer.data',
        'admin.customer.detail',
        'admin.customer.add',
        'admin.customer.edit',
        'admin.customer.save',
        'admin.customer.duplicate',

        'admin.inventory-log.index',
        'admin.inventory-log.data',
        'admin.inventory-log.detail',
        'admin.inventory-log.add',
        'admin.inventory-log.edit',
        'admin.inventory-log.save',

        'admin.complaint.index',
        'admin.complaint.data',
        'admin.complaint.add',
        'admin.complaint.edit',
        'admin.complaint.save',
        'admin.complaint.detail',

        // Penjualan (retailer sales)
        'admin.sale.index',
        'admin.sale.data',
        'admin.sale.distributor-stocks',
        'admin.sale.distributor-detail',
        'admin.sale.add',
        'admin.sale.edit',
        'admin.sale.save',
        'admin.sale.release-data',
        'admin.sale.release',
        'admin.sale.delete',
        'admin.sale.detail',

        // Territory API
        'admin.territory.api.provinces',
        'admin.territory.api.districts',
        'admin.territory.api.villages',

        // Distributor
        'admin.distributor.index',
        'admin.distributor.data',
        'admin.distributor.detail',

        // Stok Distributor (read-only)
        'admin.distributor-stock.index',
        'admin.distributor-stock.data',
    ],
    User::Role_Agronomist => [
        'admin.user.index',
        'admin.user.data',
        'admin.user.detail',
        'admin.user.export',

        'admin.product.index',
        'admin.product.data',
        'admin.product.detail',

        'admin.product-knowledge.index',
        'admin.product-knowledge.data',
        'admin.product-knowledge.harvest-data',
        'admin.product-knowledge.gallery',

        'admin.customer.index',
        'admin.customer.data',
        'admin.customer.detail',
        'admin.customer.add',
        'admin.customer.edit',
        'admin.customer.save',
        'admin.customer.duplicate',

        'admin.demo-plot.index',
        'admin.demo-plot.data',
        'admin.demo-plot.detail',
        'admin.demo-plot.export',

        'admin.demo-plot-visit.index',
        'admin.demo-plot-visit.data',
        'admin.demo-plot-visit.detail',

        'admin.activity-type.index',
        'admin.activity-type.data',

        'admin.activity-plan.index',
        'admin.activity-plan.data',
        'admin.activity-plan.detail',
        'admin.activity-plan.respond',
        'admin.activity-plan.export',

        'admin.activity-plan-detail.index',
        'admin.activity-plan-detail.data',
        'admin.activity-plan-detail.add',
        'admin.activity-plan-detail.edit',
        'admin.activity-plan-detail.save',
        'admin.activity-plan-detail.delete',

        'admin.activity.index',
        'admin.activity.data',
        'admin.activity.detail',
        'admin.activity.respond',
        'admin.activity.export',

        'admin.activity-target.index',
        'admin.activity-target.data',
        'admin.activity-target.detail',
        'admin.activity-target.add',
        'admin.activity-target.edit',
        'admin.activity-target.delete',
        'admin.activity-target.save',
        'admin.activity-target.export',

        'admin.report.index',
        'admin.report.demo-plot-detail',
        'admin.report.demo-plot-detail-with-photo',
        'admin.report.demo-activity-plan-detail',
        'admin.report.demo-activity-realization-detail',
        'admin.report.demo-activity-target-detail',

        'admin.inventory-log.index',
        'admin.inventory-log.data',
        'admin.inventory-log.detail',
        'admin.inventory-log.add',
        'admin.inventory-log.edit',
        'admin.inventory-log.save',
        'admin.inventory-log.export',

        'admin.complaint.index',
        'admin.complaint.data',
        'admin.complaint.add',
        'admin.complaint.edit',
        'admin.complaint.save',
        'admin.complaint.detail',
        'admin.complaint.respond',
        'admin.complaint.delete',
        'admin.complaint.analytics',
        'admin.complaint.analytics-data',
        'admin.complaint.map-data',
        'admin.complaint.export',

        'admin.reminder.edit',
        'admin.reminder.update',
        'admin.reminder.trigger-plan',
        'admin.reminder.trigger-report',
        'admin.notification.index',
        'admin.notification.store',

        // Penjualan (distributor purchase sales)
        'admin.sale.index',
        'admin.sale.data',
        'admin.sale.distributor-stocks',
        'admin.sale.distributor-detail',
        'admin.sale.add',
        'admin.sale.edit',
        'admin.sale.save',
        'admin.sale.delete',
        'admin.sale.detail',
        'admin.sale.export',
        'admin.sale.import',
        'admin.sale.import-template',

        // Territory API
        'admin.territory.api.provinces',
        'admin.territory.api.districts',
        'admin.territory.api.villages',

        // Distributor
        'admin.distributor.index',
        'admin.distributor.data',
        'admin.distributor.detail',

        // Stok Distributor
        'admin.distributor-stock.index',
        'admin.distributor-stock.data',
        'admin.distributor-stock.add',
        'admin.distributor-stock.save',
        'admin.distributor-stock.adjust',
        'admin.distributor-stock.movements',
        'admin.distributor-stock.movements.data',

        // Distributor Target
        'admin.distributor-target.index',
        'admin.distributor-target.data',
        'admin.distributor-target.export',
        'admin.distributor-target.add',
        'admin.distributor-target.edit',
        'admin.distributor-target.save',
        'admin.distributor-target.delete',
        'admin.distributor-target.import',

        // Analitik
        'admin.analytics.index',
        'admin.analytics.sales-chart',
    ], User::Role_ASM => [
        'admin.user.index',
        'admin.user.data',
        'admin.user.detail',
        'admin.user.export',

        'admin.product.index',
        'admin.product.data',
        'admin.product.detail',

        'admin.product-knowledge.index',
        'admin.product-knowledge.data',
        'admin.product-knowledge.harvest-data',
        'admin.product-knowledge.gallery',

        'admin.customer.index',
        'admin.customer.data',
        'admin.customer.detail',

        'admin.complaint.index',
        'admin.complaint.data',
        'admin.complaint.detail',
        'admin.complaint.analytics',
        'admin.complaint.analytics-data',
        'admin.complaint.map-data',

        'admin.activity-type.index',
        'admin.activity-type.data',

        // Penjualan (read-only for ASM)
        'admin.sale.index',
        'admin.sale.data',
        'admin.sale.distributor-stocks',
        'admin.sale.distributor-detail',
        'admin.sale.detail',

        // Distributor (read-only)
        'admin.distributor.index',
        'admin.distributor.data',
        'admin.distributor.detail',

        // Distributor Target (read-only)
        'admin.distributor-target.index',
        'admin.distributor-target.data',
        'admin.distributor-target.export',

        // Analitik
        'admin.analytics.index',
        'admin.analytics.sales-chart',
    ],
];
