<script setup>
import { computed, defineComponent, onMounted, ref, watch } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import { useQuasar } from "quasar";
import useNotificationCenter from "@/composables/useNotificationCenter";

defineComponent({
  name: "AuthenticatedLayout",
});

const LEFT_DRAWER_STORAGE_KEY = "advanta-report.layout.left-drawer-open";
const MENU_GROUP_STORAGE_KEY = "advanta-report.layout.menu-groups";
const $q = useQuasar();
const page = usePage();
const notificationMenuOpen = ref(false);
const notificationDialogOpen = ref(false);
const activeNotification = ref(null);
const notificationThreadItems = ref([]);
const notificationThreadLoading = ref(false);
const replyMessage = ref("");
const replyAttachmentFile = ref(null);
const sendingReply = ref(false);
const leftDrawerOpen = ref(
  JSON.parse(localStorage.getItem(LEFT_DRAWER_STORAGE_KEY))
);
const menuGroups = ref({
  activity: false,
  sales: false,
  master: false,
  settings: false,
});
const isDropdownOpen = ref(false);
const {
  items: notificationItems,
  unreadCount,
  isLoading: notificationsLoading,
  pushStatus,
  pushSupported,
  browserPermission,
  requestBrowserPermission,
  fetchNotifications,
  markAllAsRead,
  replyToNotification,
  fetchNotificationThread,
  openNotification,
} = useNotificationCenter();
const toggleLeftDrawer = () => (leftDrawerOpen.value = !leftDrawerOpen.value);

function canReplyNotification(item) {
  if (!item) {
    return false;
  }

  const userRole = page.props?.auth?.user?.role;
  const isBs = userRole === "bs";
  const isReadSignal = item.context_action === "read";
  const isReplySignal = item.context_action === "reply";

  return isBs && !isReadSignal && !isReplySignal && !!item.sent_by_id;
}

function isOutgoingThreadItem(item) {
  const currentUserId = Number(page.props?.auth?.user?.id || 0);
  return Number(item?.sent_by_id || 0) === currentUserId || item?.context_action === "reply_sent";
}

function isReadReceiptItem(item) {
  return item?.context_action === "read";
}

const visibleThreadItems = computed(() => {
  return (notificationThreadItems.value || []).filter((item) => !isReadReceiptItem(item));
});

function isThreadItemRead(item) {
  if (!item?.id || !isOutgoingThreadItem(item)) {
    return false;
  }

  return (notificationThreadItems.value || []).some((entry) => {
    if (entry?.context_action !== "read") {
      return false;
    }

    return String(entry?.context_id || "") === String(item.id);
  });
}

function threadDisplayMessage(item) {
  return (item?.reply_message || item?.message || "").trim();
}

async function loadNotificationThread(item) {
  if (!item?.id) {
    notificationThreadItems.value = [];
    return;
  }

  notificationThreadLoading.value = true;

  try {
    const payload = await fetchNotificationThread(item.id);
    notificationThreadItems.value = payload.items || [];
  } catch (error) {
    notificationThreadItems.value = [];
    $q.notify({
      color: "warning",
      message: "Riwayat percakapan belum bisa dimuat.",
      position: "top",
    });
  } finally {
    notificationThreadLoading.value = false;
  }
}

async function openNotificationDialog(item) {
  activeNotification.value = item;
  replyMessage.value = "";
  replyAttachmentFile.value = null;
  notificationThreadItems.value = [];
  notificationDialogOpen.value = true;

  await openNotification(item, { navigate: false });
  await loadNotificationThread(item);
}

async function sendReplyFromDialog() {
  if (!activeNotification.value || !canReplyNotification(activeNotification.value)) {
    return;
  }

  const message = (replyMessage.value || "").trim();
  const attachmentFile = replyAttachmentFile.value || null;

  if (!message && !attachmentFile) {
    $q.notify({
      color: "warning",
      message: "Isi balasan atau lampiran harus diisi.",
      position: "top",
    });
    return;
  }

  sendingReply.value = true;

  try {
    await replyToNotification(activeNotification.value.id, message, attachmentFile);
    replyMessage.value = "";
    replyAttachmentFile.value = null;
    await loadNotificationThread(activeNotification.value);
    $q.notify({
      color: "positive",
      message: "Balasan berhasil dikirim.",
      position: "top",
    });
  } catch (error) {
    $q.notify({
      color: "negative",
      message: "Balasan gagal dikirim. Silakan coba lagi.",
      position: "top",
    });
  } finally {
    sendingReply.value = false;
  }
}

function formatNotificationDate(value) {
  if (!value) {
    return "-";
  }

  try {
    return new Intl.DateTimeFormat("id-ID", {
      dateStyle: "medium",
      timeStyle: "short",
    }).format(new Date(value));
  } catch {
    return value;
  }
}

watch(leftDrawerOpen, (newValue) => {
  localStorage.setItem(LEFT_DRAWER_STORAGE_KEY, newValue);
});

watch(
  menuGroups,
  (newValue) => {
    localStorage.setItem(MENU_GROUP_STORAGE_KEY, JSON.stringify(newValue));
  },
  { deep: true }
);

onMounted(() => {
  leftDrawerOpen.value = JSON.parse(
    localStorage.getItem(LEFT_DRAWER_STORAGE_KEY)
  );

  if ($q.screen.lt.md) {
    leftDrawerOpen.value = false;
  }

  const savedMenuGroups = localStorage.getItem(MENU_GROUP_STORAGE_KEY);
  if (savedMenuGroups) {
    menuGroups.value = JSON.parse(savedMenuGroups);
    return;
  }

  const currentPath = page.url || "";
  menuGroups.value = {
    activity:
      currentPath.startsWith("/admin/activities") ||
      currentPath.startsWith("/admin/activity-plans") ||
      currentPath.startsWith("/admin/demo-plots") ||
      currentPath.startsWith("/admin/activity-targets") ||
      currentPath.startsWith("/admin/inventory-logs") ||
      currentPath.startsWith("/admin/activity-types"),
    sales:
      currentPath.startsWith("/admin/sales") ||
      currentPath.startsWith("/admin/distributors") ||
      currentPath.startsWith("/admin/distributor-stocks") ||
      currentPath.startsWith("/admin/distributor-targets") ||
      currentPath.startsWith("/admin/market-insights") ||
      currentPath.startsWith("/admin/analytics"),
    master:
      currentPath.startsWith("/admin/customers") ||
      currentPath.startsWith("/admin/products") ||
      currentPath.startsWith("/admin/product-categories") ||
      currentPath.startsWith("/admin/product-knowledge"),
    settings:
      currentPath.startsWith("/admin/settings/users") ||
      currentPath.startsWith("/admin/settings/profile") ||
      currentPath.startsWith("/admin/settings/company-profile") ||
      currentPath.startsWith("/admin/settings/reminders") ||
      currentPath.startsWith("/admin/settings/notifications") ||
      currentPath.startsWith("/admin/settings/db"),
  };
});
</script>

<template>
  <q-layout view="lHh LpR lFf">
    <q-header class="bg-white text-dark">
      <q-toolbar class="bg-grey-1 text-black toolbar-scrolled">
        <q-btn
          v-if="!leftDrawerOpen"
          flat
          dense
          aria-label="Menu"
          @click="toggleLeftDrawer"
        >
          <q-icon class="material-symbols-outlined">dock_to_right</q-icon>
        </q-btn>
        <slot name="left-button"></slot>
        <q-toolbar-title
          :class="{ 'q-ml-sm': leftDrawerOpen }"
          style="font-size: 18px"
        >
          <slot name="title">{{ $config.APP_NAME }}</slot>
        </q-toolbar-title>
        <slot name="right-button"></slot>
        <q-btn
          flat
          round
          dense
          icon="notifications"
          @click="fetchNotifications()"
        >
          <q-badge
            v-if="unreadCount > 0"
            floating
            rounded
            color="red"
            :label="unreadCount > 99 ? '99+' : unreadCount"
          />
          <q-menu
            v-model="notificationMenuOpen"
            anchor="bottom right"
            self="top right"
            @before-show="fetchNotifications()"
          >
            <q-list style="min-width: 320px; max-width: 360px">
              <q-item>
                <q-item-section>
                  <q-item-label class="text-weight-bold">Pengumuman</q-item-label>
                  <q-item-label caption>
                    {{ unreadCount }} belum dibaca
                  </q-item-label>
                  <q-item-label caption v-if="pushSupported">
                    Status browser notif: {{ pushStatus }}
                  </q-item-label>
                </q-item-section>
                <q-item-section side>
                  <q-btn
                    v-if="pushSupported && browserPermission !== 'granted'"
                    flat
                    dense
                    no-caps
                    size="sm"
                    label="Aktifkan"
                    @click.stop="requestBrowserPermission"
                  />
                  <q-btn
                    v-if="unreadCount > 0"
                    flat
                    dense
                    no-caps
                    size="sm"
                    label="Tandai semua"
                    @click.stop="markAllAsRead"
                  />
                </q-item-section>
              </q-item>
              <q-separator />

              <q-item v-if="notificationsLoading">
                <q-item-section>
                  <q-item-label class="text-grey-7">Memuat pengumuman...</q-item-label>
                </q-item-section>
              </q-item>

              <q-item
                v-for="item in notificationItems"
                :key="item.id"
                clickable
                v-ripple
                @click="openNotificationDialog(item)"
              >
                <q-item-section avatar>
                  <q-icon :name="item.read_at ? 'drafts' : 'mark_email_unread'" />
                </q-item-section>
                <q-item-section>
                  <q-item-label class="text-weight-medium">{{ item.title }}</q-item-label>
                  <q-item-label caption lines="2">{{ item.message }}</q-item-label>
                  <q-item-label caption class="text-grey-7 q-mt-xs">
                    {{ formatNotificationDate(item.created_at) }}
                  </q-item-label>
                </q-item-section>
                <q-item-section side>
                  <q-btn
                    v-if="canReplyNotification(item)"
                    flat
                    dense
                    no-caps
                    size="sm"
                    label="Balas"
                    @click.stop="openNotificationDialog(item)"
                  />
                </q-item-section>
              </q-item>

              <q-item v-if="!notificationsLoading && notificationItems.length === 0">
                <q-item-section>
                  <q-item-label class="text-grey-7">Belum ada pengumuman.</q-item-label>
                </q-item-section>
              </q-item>
            </q-list>
          </q-menu>
        </q-btn>
      </q-toolbar>
      <slot name="header"></slot>
    </q-header>
    <q-drawer
      :breakpoint="768"
      v-model="leftDrawerOpen"
      bordered
      class="bg-grey-2"
      style="color: #444"
    >
      <div
        class="absolute-top"
        style="
          height: 50px;
          border-bottom: 1px solid #ddd;
          align-items: center;
          justify-content: center;
        "
      >
        <div
          style="
            width: 100%;
            padding: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
          "
        >
          <q-btn-dropdown
            v-model="isDropdownOpen"
            class="profile-btn text-bold"
            flat
            :label="page.props.auth.user.company_name"
            style="
              justify-content: space-between;
              flex-grow: 1;
              overflow: hidden;
            "
            :class="{ 'profile-btn-active': isDropdownOpen }"
          >
            <q-list id="profile-btn-popup" style="color: #444">
              <q-item>
                <q-avatar style="margin-left: -15px"
                  ><q-icon name="person"
                /></q-avatar>
                <q-item-section>
                  <q-item-label>
                    <div class="text-bold">{{ page.props.auth.user.name }}</div>
                    <div class="text-grey-8 text-caption">
                      {{ $CONSTANTS.USER_ROLES[page.props.auth.user.role] }} @
                      {{ page.props.auth.user.company_name }}
                    </div>
                  </q-item-label>
                </q-item-section>
              </q-item>
              <q-separator />
              <q-item
                v-close-popup
                class="subnav"
                clickable
                v-ripple
                :active="$page.url.startsWith('/admin/settings/profile')"
                @click="router.get(route('admin.profile.edit'))"
              >
                <q-item-section>
                  <q-item-label
                    ><q-icon name="manage_accounts" class="q-mr-sm" />
                    {{ $t("my_profile") }}</q-item-label
                  >
                </q-item-section>
              </q-item>
              <q-item
                v-close-popup
                v-if="$page.props.auth.user.role == $CONSTANTS.USER_ROLE_ADMIN"
                class="subnav"
                clickable
                v-ripple
                :active="
                  $page.url.startsWith('/admin/settings/company-profile')
                "
                @click="router.get(route('admin.company-profile.edit'))"
              >
                <q-item-section>
                  <q-item-label
                    ><q-icon name="home_work" class="q-mr-sm" />
                    {{ $t("company_profile") }}</q-item-label
                  >
                </q-item-section>
              </q-item>
            </q-list>
          </q-btn-dropdown>
          <div class="row items-center no-wrap q-gutter-xs">
            <q-btn
              v-if="leftDrawerOpen"
              flat
              dense
              aria-label="Menu"
              @click="toggleLeftDrawer"
            >
              <q-icon name="dock_to_right" />
            </q-btn>
          </div>
        </div>
      </div>
      <q-scroll-area style="height: calc(100% - 50px); margin-top: 50px">
        <q-list id="main-nav" style="margin-bottom: 50px">
          <q-item
            clickable
            v-ripple
            :active="$page.url.startsWith('/admin/dashboard')"
            @click="router.get(route('admin.dashboard'))"
          >
            <q-item-section avatar>
              <q-icon name="dashboard" />
            </q-item-section>
            <q-item-section>
              <q-item-label>Dashboard</q-item-label>
            </q-item-section>
          </q-item>
          <q-item
            v-if="$can('admin.report.index')"
            clickable
            v-ripple
            :active="$page.url.startsWith('/admin/reports')"
            @click="router.get(route('admin.report.index'))"
          >
            <q-item-section avatar>
              <q-icon name="docs" />
            </q-item-section>
            <q-item-section>
              <q-item-label>Laporan</q-item-label>
            </q-item-section>
          </q-item>
          <q-separator />

          <q-expansion-item
            v-if="
              $can('admin.activity.index') ||
              $can('admin.activity-plan.index') ||
              $can('admin.demo-plot.index') ||
              $can('admin.activity-target.index') ||
              $can('admin.inventory-log.index') ||
              $can('admin.activity-type.index') ||
              $can('admin.complaint.index') ||
              $can('admin.complaint.analytics')
            "
            v-model="menuGroups.activity"
            icon="event"
            label="Aktivitas"
            dense-toggle
            expand-separator
            :header-class="$page.url.startsWith('/admin/activities') ||
              $page.url.startsWith('/admin/activity-plans') ||
              $page.url.startsWith('/admin/demo-plots') ||
              $page.url.startsWith('/admin/activity-targets') ||
              $page.url.startsWith('/admin/inventory-logs') ||
                $page.url.startsWith('/admin/activity-types') ||
                $page.url.startsWith('/admin/complaints')
              ? 'text-primary'
              : ''"
          >
            <q-item
              v-if="$can('admin.activity.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/activities')"
              @click="router.get(route('admin.activity.index'))"
            >
              <q-item-section avatar>
                <q-icon name="event" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Realisasi Kegiatan</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.activity-plan.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/activity-plans')"
              @click="router.get(route('admin.activity-plan.index'))"
            >
              <q-item-section avatar>
                <q-icon name="event_upcoming" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Rencana Kegiatan</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.demo-plot.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/demo-plots')"
              @click="router.get(route('admin.demo-plot.index'))"
            >
              <q-item-section avatar>
                <q-icon name="assignment" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Demplot</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              clickable
              v-if="$can('admin.activity-target.index')"
              v-ripple
              :active="$page.url.startsWith('/admin/activity-targets')"
              @click="router.get(route('admin.activity-target.index'))"
            >
              <q-item-section avatar>
                <q-icon name="target" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Target Kegiatan</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.inventory-log.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/inventory-logs')"
              @click="router.get(route('admin.inventory-log.index'))"
            >
              <q-item-section avatar>
                <q-icon name="inventory" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Log Inventori</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.complaint.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/complaints') && !$page.url.includes('/analytics')"
              @click="router.get(route('admin.complaint.index'))"
            >
              <q-item-section avatar>
                <q-icon name="report_problem" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Complaint Intelligence</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.complaint.analytics')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/complaints/analytics')"
              @click="router.get(route('admin.complaint.analytics'))"
            >
              <q-item-section avatar>
                <q-icon name="analytics" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Complaint Analytics</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.activity-type.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/activity-types')"
              @click="router.get(route('admin.activity-type.index'))"
            >
              <q-item-section avatar>
                <q-icon name="activity_zone" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Jenis Kegiatan (DGA)</q-item-label>
              </q-item-section>
            </q-item>
          </q-expansion-item>

          <q-expansion-item
            v-if="
              $can('admin.sale.index') ||
              $can('admin.distributor.index') ||
              $can('admin.distributor-stock.index') ||
              $can('admin.distributor-target.index') ||
              $can('admin.market-insight.index') ||
              $can('admin.analytics.index')
            "
            v-model="menuGroups.sales"
            icon="receipt_long"
            label="Penjualan"
            dense-toggle
            expand-separator
            :header-class="$page.url.startsWith('/admin/sales') ||
              $page.url.startsWith('/admin/distributors') ||
              $page.url.startsWith('/admin/distributor-stocks') ||
              $page.url.startsWith('/admin/distributor-targets') ||
              $page.url.startsWith('/admin/market-insights') ||
              $page.url.startsWith('/admin/analytics')
              ? 'text-primary'
              : ''"
          >
            <q-item
              v-if="$can('admin.sale.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/sales') && !$page.url.includes('mode=bs-inbox')"
              @click="router.get(route('admin.sale.index'))"
            >
              <q-item-section avatar>
                <q-icon name="receipt_long" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Penjualan</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.sale.index') && ['admin', 'agronomist'].includes($page.props.auth.user.role)"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/sales') && $page.url.includes('mode=bs-inbox')"
              @click="router.get(route('admin.sale.index', { mode: 'bs-inbox' }))"
            >
              <q-item-section avatar>
                <q-icon name="fact_check" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Review Penjualan BS</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.distributor.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/distributors')"
              @click="router.get(route('admin.distributor.index'))"
            >
              <q-item-section avatar>
                <q-icon name="warehouse" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Distributor</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.distributor-stock.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/distributor-stocks')"
              @click="router.get(route('admin.distributor-stock.index'))"
            >
              <q-item-section avatar>
                <q-icon name="inventory_2" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Stok Distributor</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.distributor-target.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/distributor-targets')"
              @click="router.get(route('admin.distributor-target.index'))"
            >
              <q-item-section avatar>
                <q-icon name="flag" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Target Distributor</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.market-insight.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/market-insights')"
              @click="router.get(route('admin.market-insight.index'))"
            >
              <q-item-section avatar>
                <q-icon name="insights" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Market Insight</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.analytics.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/analytics')"
              @click="router.get(route('admin.analytics.index'))"
            >
              <q-item-section avatar>
                <q-icon name="bar_chart" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Analitik</q-item-label>
              </q-item-section>
            </q-item>
          </q-expansion-item>

          <q-expansion-item
            v-if="
              $can('admin.customer.index') ||
              $can('admin.product.index') ||
              $can('admin.product-category.index') ||
              $can('admin.product-knowledge.index') ||
              $can('admin.harvest-result.index')
            "
            v-model="menuGroups.master"
            icon="inventory_2"
            label="Master Data"
            dense-toggle
            expand-separator
            :header-class="$page.url.startsWith('/admin/customers') ||
              $page.url.startsWith('/admin/products') ||
              $page.url.startsWith('/admin/product-categories') ||
              $page.url.startsWith('/admin/product-knowledge') ||
              $page.url.startsWith('/admin/harvest-result')
              ? 'text-primary'
              : ''"
          >
            <q-item
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/customers')"
              v-if="$can('admin.customer.index')"
              @click="router.get(route('admin.customer.index'))"
            >
              <q-item-section avatar>
                <q-icon name="storefront" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Client</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              clickable
              v-if="$can('admin.product.index')"
              v-ripple
              :active="$page.url.startsWith('/admin/products')"
              @click="router.get(route('admin.product.index'))"
            >
              <q-item-section avatar>
                <q-icon name="potted_plant" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Varietas Tanaman</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.product-category.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/product-categories')"
              @click="router.get(route('admin.product-category.index'))"
            >
              <q-item-section avatar>
                <q-icon name="category" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Kategori Varietas</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.product-knowledge.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/product-knowledge')"
              @click="router.get(route('admin.product-knowledge.index'))"
            >
              <q-item-section avatar>
                <q-icon name="photo_library" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Product Knowledge</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.harvest-result.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/harvest-result')"
              @click="router.get(route('admin.harvest-result.index'))"
            >
              <q-item-section avatar>
                <q-icon name="agriculture" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Hasil Panen</q-item-label>
              </q-item-section>
            </q-item>
          </q-expansion-item>

          <q-expansion-item
            v-model="menuGroups.settings"
            icon="settings"
            label="Pengaturan"
            dense-toggle
            expand-separator
            :header-class="$page.url.startsWith('/admin/settings/users') ||
              $page.url.startsWith('/admin/settings/profile') ||
              $page.url.startsWith('/admin/settings/company-profile') ||
              $page.url.startsWith('/admin/settings/reminders') ||
              $page.url.startsWith('/admin/settings/notifications') ||
              $page.url.startsWith('/admin/settings/db')
              ? 'text-primary'
              : ''"
          >
            <q-item
              v-if="$can('admin.user.index')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/settings/users')"
              @click="router.get(route('admin.user.index'))"
            >
              <q-item-section avatar>
                <q-icon name="group" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Pengguna</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/settings/profile')"
              @click="router.get(route('admin.profile.edit'))"
            >
              <q-item-section avatar>
                <q-icon name="manage_accounts" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Profil Saya</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.company-profile.edit')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/settings/company-profile')"
              @click="router.get(route('admin.company-profile.edit'))"
            >
              <q-item-section avatar>
                <q-icon name="apartment" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Profil Perusahaan</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="$can('admin.reminder.edit') || ['admin', 'agronomist'].includes($page.props.auth.user.role)"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/settings/reminders')"
              @click="router.get(route('admin.reminder.edit'))"
            >
              <q-item-section avatar>
                <q-icon name="notifications_active" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Reminder WA</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-if="['admin', 'agronomist'].includes($page.props.auth.user.role)"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/settings/notifications')"
              @click="router.get(route('admin.notification.index'))"
            >
              <q-item-section avatar>
                <q-icon name="campaign" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Pengumuman BS</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-close-popup
              v-if="$can('admin.db.menu')"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/settings/db')"
              @click="router.get(route('admin.db.index'))"
            >
              <q-item-section avatar>
                <q-icon name="database" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Database</q-item-label>
              </q-item-section>
            </q-item>
          </q-expansion-item>

          <q-separator class="q-my-sm" />
          <q-item
            clickable
            v-ripple
            style="color: inherit"
            :href="route('admin.auth.logout')"
          >
            <q-item-section avatar>
              <q-icon name="logout" />
            </q-item-section>
            <q-item-section>
              <q-item-label>Keluar</q-item-label>
            </q-item-section>
          </q-item>

          <div class="absolute-bottom text-grey-6 q-pa-md">
            <div>
              {{ $config.APP_NAME + " v" + $config.APP_VERSION_STR }}
            </div>
            <div class="q-mt-xs">
              &copy;2025
              <a href="https://shiftech.my.id">Shiftech Indonesia</a>
            </div>
          </div>
        </q-list>
      </q-scroll-area>
    </q-drawer>
    <q-page-container class="bg-grey-1">
      <q-page>
        <slot></slot>
      </q-page>
    </q-page-container>

    <q-dialog v-model="notificationDialogOpen" persistent>
      <q-card style="min-width: 320px; max-width: 560px; width: 92vw">
        <q-card-section>
          <div class="text-subtitle1 text-weight-bold">
            {{ activeNotification?.title || "Detail Pengumuman" }}
          </div>
          <div class="text-caption text-grey-7 q-mt-xs">
            Dari: {{ activeNotification?.sent_by_name || "Sistem" }}
            <span v-if="activeNotification?.sent_by_role">
              ({{ activeNotification?.sent_by_role }})
            </span>
          </div>
          <div class="text-caption text-grey-7">
            {{ formatNotificationDate(activeNotification?.created_at) }}
          </div>
        </q-card-section>

        <q-separator />

        <q-card-section>
          <div style="white-space: pre-wrap; line-height: 1.5">
            {{ activeNotification?.message || "-" }}
          </div>

          <div v-if="activeNotification?.attachment_url" class="q-mt-md">
            <q-img
              v-if="activeNotification?.attachment_is_image"
              :src="activeNotification.attachment_url"
              fit="contain"
              style="max-height: 240px; border-radius: 8px"
            />
            <q-btn
              v-else
              flat
              dense
              no-caps
              color="primary"
              icon="attach_file"
              :label="activeNotification?.attachment_name || 'Lihat lampiran'"
              :href="activeNotification.attachment_url"
              target="_blank"
            />
          </div>
        </q-card-section>

        <q-separator />

        <q-card-section>
          <div class="text-subtitle2 q-mb-sm">Percakapan</div>

          <div v-if="notificationThreadLoading" class="row items-center q-gutter-sm text-grey-7">
            <q-spinner size="18px" />
            <span>Memuat percakapan...</span>
          </div>

          <div
            v-else-if="visibleThreadItems.length > 0"
            class="column q-gutter-sm"
            style="max-height: 280px; overflow-y: auto"
          >
            <div
              v-for="threadItem in visibleThreadItems"
              :key="threadItem.id"
              class="q-pa-sm"
              :class="isOutgoingThreadItem(threadItem) ? 'bg-blue-1 self-end' : 'bg-grey-3 self-start'"
              style="border-radius: 10px; max-width: 90%"
            >
              <div class="text-caption text-grey-7 q-mb-xs">
                {{ isOutgoingThreadItem(threadItem) ? "Anda" : (threadItem.sent_by_name || "Pengirim") }}
                - {{ formatNotificationDate(threadItem.created_at) }}
              </div>

              <div style="white-space: pre-wrap; line-height: 1.45">
                {{ threadDisplayMessage(threadItem) || "(tanpa teks)" }}
              </div>

              <div
                v-if="isOutgoingThreadItem(threadItem)"
                class="text-caption text-grey-7 q-mt-xs"
                style="text-align: right"
              >
                <q-icon
                  v-if="isThreadItemRead(threadItem)"
                  name="done_all"
                  size="16px"
                  color="primary"
                />
                <q-icon
                  v-else
                  name="done"
                  size="16px"
                  color="grey-7"
                />
              </div>

              <div v-if="threadItem.attachment_url" class="q-mt-sm">
                <q-img
                  v-if="threadItem.attachment_is_image"
                  :src="threadItem.attachment_url"
                  fit="contain"
                  style="max-height: 180px; border-radius: 8px"
                />
                <q-btn
                  v-else
                  flat
                  dense
                  no-caps
                  color="primary"
                  icon="attach_file"
                  :label="threadItem.attachment_name || 'Lihat lampiran'"
                  :href="threadItem.attachment_url"
                  target="_blank"
                />
              </div>
            </div>
          </div>

          <div v-else class="text-caption text-grey-7">
            Belum ada riwayat percakapan.
          </div>
        </q-card-section>

        <q-card-section v-if="canReplyNotification(activeNotification)">
          <q-input
            v-model="replyMessage"
            type="textarea"
            autogrow
            outlined
            label="Balas pesan"
            hint="Balasan ini akan dikirim ke Agronomis/Admin pengirim."
          />

          <q-file
            v-model="replyAttachmentFile"
            class="q-mt-sm"
            outlined
            clearable
            accept=".jpg,.jpeg,.png,.webp,.gif,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.zip,.rar,.txt"
            label="Lampirkan gambar / file"
            hint="Maksimal 10 MB"
          >
            <template #prepend>
              <q-icon name="attach_file" />
            </template>
          </q-file>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Tutup" v-close-popup />
          <q-btn
            v-if="activeNotification?.url"
            flat
            color="primary"
            label="Buka"
            @click="openNotification(activeNotification, { navigate: true })"
          />
          <q-btn
            v-if="canReplyNotification(activeNotification)"
            unelevated
            color="primary"
            label="Kirim Balasan"
            :loading="sendingReply"
            @click="sendReplyFromDialog"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <slot name="footer"></slot>
  </q-layout>
</template>

<style>
.profile-btn span.block {
  text-align: left !important;
  width: 100% !important;
  margin-left: 10px !important;
}
</style>
<style scoped>
.q-toolbar {
  border-bottom: 1px solid transparent;
  /* Optional border line */
}

.toolbar-scrolled {
  box-shadow: 0px 1px 2px rgba(0, 0, 0, 0.05);
  /* Add shadow */
  border-bottom: 1px solid #ddd;
  /* Optional border line */
}

.profile-btn-active {
  background-color: #ddd !important;
}

#profile-btn-popup .q-item--active {
  color: inherit !important;
}
</style>
