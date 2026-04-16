<?php

namespace Tests\Feature;

use App\Http\Middleware\AutoPermissionMiddleware;
use App\Models\Customer;
use App\Models\DistributorStock;
use App\Models\InventoryLog;
use App\Models\StockMovement;
use App\Models\Product;
use App\Models\ProductCategory;
use App\Models\Sale;
use App\Models\SaleItem;
use App\Models\User;
use App\Services\FonteWhatsAppService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SaleReleaseInventoryTest extends TestCase
{
    use RefreshDatabase;

    public function test_releasing_retailer_sale_reduces_client_inventory_log_and_distributor_stock(): void
    {
        $this->mockFonteWhatsAppService();

        $admin = $this->createAdminUser();
        $product = $this->createProduct();
        $distributor = $this->createCustomer(Customer::Type_Distributor, 'Distributor A');
        $retailer = $this->createCustomer(Customer::Type_R1, 'Retailer A');

        $this->actingAs($admin);
        $this->seedInitialStock($distributor->id, $product->id, 'LOT-001', 10);
        $this->seedClientInventoryLog($retailer->id, $product->id, 'LOT-001', 10);

        $sale = Sale::create([
            'date' => now()->toDateString(),
            'sale_type' => Sale::Type_Retailer,
            'status' => Sale::Status_Pending,
            'source_from' => Sale::Source_Distributor,
            'distributor_id' => $distributor->id,
            'retailer_id' => $retailer->id,
            'notes' => 'Test release sale',
            'total_amount' => 30000,
        ]);

        $saleItem = SaleItem::create([
            'sale_id' => $sale->id,
            'product_id' => $product->id,
            'lot_number' => 'LOT-001',
            'expired_date' => null,
            'quantity' => 3,
            'unit' => 'kg',
            'price' => 10000,
            'subtotal' => 30000,
        ]);

        $response = $this
            ->withoutMiddleware(AutoPermissionMiddleware::class)
            ->post(route('admin.sale.release', $sale->id), [
                'items' => [[
                    'id' => $saleItem->id,
                    'quantity' => 3,
                    'unit' => 'kg',
                    'remaining_stock' => 7,
                    'lot_number' => 'LOT-001',
                    'expired_date' => null,
                ]],
            ]);

        $response->assertOk()->assertJson(['message' => 'PO berhasil di-release.']);

        $this->assertSame('released', $sale->fresh()->status);

        $stockQty = (float) (StockMovement::query()
            ->where('distributor_id', $distributor->id)
            ->where('product_id', $product->id)
            ->selectRaw("COALESCE(SUM(CASE WHEN type = 'in' THEN quantity ELSE -quantity END), 0) as qty")
            ->value('qty') ?? 0);
        $this->assertSame(7.0, $stockQty);

        $distributorStock = DistributorStock::query()
            ->where('distributor_id', $distributor->id)
            ->where('product_id', $product->id)
            ->value('stock_quantity');
        $this->assertSame(7.0, (float) $distributorStock);

        $saleInventoryLog = InventoryLog::query()
            ->where('reference_sale_id', $sale->id)
            ->where('customer_id', $retailer->id)
            ->where('product_id', $product->id)
            ->where('lot_package', 'LOT-001')
            ->first();

        $this->assertNotNull($saleInventoryLog);
        $this->assertSame(7.0, (float) $saleInventoryLog->quantity);
        $this->assertSame(7, (int) $saleInventoryLog->base_quantity);
        $this->assertStringContainsString('[SALE_SYNC#' . $sale->id . '] OUT via sales', (string) $saleInventoryLog->notes);
    }

    public function test_deleting_released_retailer_sale_restores_stock_and_removes_sale_inventory_log(): void
    {
        $this->mockFonteWhatsAppService();

        $admin = $this->createAdminUser();
        $product = $this->createProduct();
        $distributor = $this->createCustomer(Customer::Type_Distributor, 'Distributor B');
        $retailer = $this->createCustomer(Customer::Type_R1, 'Retailer B');

        $this->actingAs($admin);
        $this->seedInitialStock($distributor->id, $product->id, 'LOT-002', 10);
        $this->seedClientInventoryLog($retailer->id, $product->id, 'LOT-002', 10);

        $sale = Sale::create([
            'date' => now()->toDateString(),
            'sale_type' => Sale::Type_Retailer,
            'status' => Sale::Status_Pending,
            'source_from' => Sale::Source_Distributor,
            'distributor_id' => $distributor->id,
            'retailer_id' => $retailer->id,
            'notes' => 'Test delete sale',
            'total_amount' => 30000,
        ]);

        $saleItem = SaleItem::create([
            'sale_id' => $sale->id,
            'product_id' => $product->id,
            'lot_number' => 'LOT-002',
            'expired_date' => null,
            'quantity' => 3,
            'unit' => 'kg',
            'price' => 10000,
            'subtotal' => 30000,
        ]);

        $this
            ->withoutMiddleware(AutoPermissionMiddleware::class)
            ->post(route('admin.sale.release', $sale->id), [
                'items' => [[
                    'id' => $saleItem->id,
                    'quantity' => 3,
                    'unit' => 'kg',
                    'remaining_stock' => 7,
                    'lot_number' => 'LOT-002',
                    'expired_date' => null,
                ]],
            ])
            ->assertOk();

        $deleteResponse = $this
            ->withoutMiddleware(AutoPermissionMiddleware::class)
            ->post(route('admin.sale.delete', $sale->id));

        $deleteResponse->assertOk()->assertJson(['message' => 'Penjualan berhasil dihapus.']);

        $this->assertNull(Sale::query()->find($sale->id));

        $stockQty = (float) (StockMovement::query()
            ->where('distributor_id', $distributor->id)
            ->where('product_id', $product->id)
            ->selectRaw("COALESCE(SUM(CASE WHEN type = 'in' THEN quantity ELSE -quantity END), 0) as qty")
            ->value('qty') ?? 0);
        $this->assertSame(10.0, $stockQty);

        $this->assertFalse(
            InventoryLog::query()
                ->where('reference_sale_id', $sale->id)
                ->exists()
        );
    }

    private function createAdminUser(): User
    {
        return User::create([
            'name' => 'Admin Test',
            'username' => 'admin-test-' . uniqid(),
            'password' => 'password',
            'role' => User::Role_Admin,
            'active' => true,
            'work_area' => 'Test Area',
        ]);
    }

    private function createCustomer(string $type, string $name): Customer
    {
        return Customer::create([
            'name' => $name,
            'type' => $type,
            'phone' => '08123456789',
            'address' => 'Test Address',
            'shipping_address' => 'Test Address',
            'active' => true,
        ]);
    }

    private function createProduct(): Product
    {
        $category = ProductCategory::create([
            'name' => 'Test Category ' . uniqid(),
            'description' => 'Test category',
        ]);

        return Product::create([
            'category_id' => $category->id,
            'name' => 'Test Product ' . uniqid(),
            'price_1' => 10000,
            'uom_1' => 'kg',
            'price_2' => 0,
            'uom_2' => '',
            'active' => true,
            'weight' => null,
        ]);
    }

    private function seedInitialStock(int $distributorId, int $productId, string $lotNumber, float $quantity): void
    {
        StockMovement::create([
            'distributor_id' => $distributorId,
            'product_id' => $productId,
            'type' => 'in',
            'quantity' => $quantity,
            'reference' => 'seed',
            'lot_number' => $lotNumber,
            'expired_date' => null,
            'notes' => 'Initial stock',
        ]);
    }

    private function seedClientInventoryLog(int $customerId, int $productId, string $lotNumber, float $quantity): void
    {
        InventoryLog::create([
            'product_id' => $productId,
            'customer_id' => $customerId,
            'user_id' => auth()->id(),
            'check_date' => now()->toDateString(),
            'area' => 'Test Area',
            'lot_package' => $lotNumber,
            'quantity' => $quantity,
            'base_quantity' => (int) $quantity,
            'notes' => 'Initial inventory',
        ]);
    }

    private function mockFonteWhatsAppService(): void
    {
        $this->mock(FonteWhatsAppService::class, function ($mock) {
            $mock->shouldReceive('sendSaleReleasedNotificationToOwner')->andReturn(true);
            $mock->shouldReceive('sendSaleReleasedNotificationToBs')->andReturn(true);
        });
    }
}