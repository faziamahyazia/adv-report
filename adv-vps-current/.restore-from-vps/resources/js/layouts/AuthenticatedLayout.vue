<script setup>
import { computed, defineComponent, onBeforeUnmount, onMounted, ref, watch } from "vue";
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
const notificationDetailOpen = ref(false);
const selectedNotification = ref(null);
const pushPromptOpen = ref(false);
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
let globalRealtimeChannel = null;
let syncTimerId = null;
const toggleLeftDrawer = () => (leftDrawerOpen.value = !leftDrawerOpen.value);
const canManageInfoNotifications = computed(() =>
  ["admin", "agronomist"].includes(page.props.auth.user.role)
);
const {
  items: notificationItems,
  unreadCount,
  isLoading: notificationsLoading,
  pushStatus,
  pushSupported,
  browserPermission,
  fetchNotifications,
  syncPushStatus,
  requestBrowserPermission,
  markAllAsRead,
  openNotification,
} = useNotificationCenter();

const routeModuleMap = [
  { module: "dashboard", paths: ["/admin/dashboard"] },
  { module: "activity", paths: ["/admin/activities", "/admin/activity-plans", "/admin/activity-targets", "/admin/demo-plots", "/admin/demo-plot-vistis", "/admin/demo-plot-visits", "/admin/inventory-logs", "/admin/activity-types", "/admin/complaints"] },
  { module: "sales", paths: ["/admin/sales", "/admin/distributors", "/admin/distributor-stocks", "/admin/distributor-targets", "/admin/analytics"] },
  { module: "master", paths: ["/admin/products", "/admin/product-categories", "/admin/product-knowledge", "/admin/customers", "/admin/settings/users"] },
];

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

async function showNotificationDetail(item) {
  await openNotification(item, {
    navigate: false,
    showReadToast: false,
  });

  const latestItem = notificationItems.value.find((nextItem) => nextItem.id === item.id);
  selectedNotification.value = latestItem || {
    ...item,
    read_at: item.read_at || new Date().toISOString(),
  };
  notificationDetailOpen.value = true;
}

function openNotificationTarget() {
  const targetUrl = selectedNotification.value?.url;

  if (!targetUrl) {
    return;
  }

  notificationDetailOpen.value = false;
  window.location.assign(targetUrl);
}

function resolveCurrentModule() {
  const currentPath = page.url || "";

  for (const entry of routeModuleMap) {
    if (entry.paths.some((path) => currentPath.startsWith(path))) {
      return entry.module;
    }
  }

  return null;
}

function queueRealtimeSync() {
  if (syncTimerId) {
    window.clearTimeout(syncTimerId);
  }

  console.debug("[Realtime] Queuing page reload (250ms debounce)");
  syncTimerId = window.setTimeout(() => {
    console.info("[Realtime] Executing page reload");
    router.reload({ preserveScroll: true });
  }, 250);
}

function handleRealtimeNotification(event) {
  const payload = event?.detail || {};
  const actorId = payload?.sent_by_id ?? null;

  if (actorId && Number(actorId) === Number(page.props?.auth?.user?.id)) {
    return;
  }

  if (payload?.context !== "complaint") {
    return;
  }

  const currentPath = page.url || "";
  const isComplaintSurface =
    currentPath.startsWith("/admin/complaints") ||
    currentPath.startsWith("/admin/dashboard");

  if (!isComplaintSurface) {
    return;
  }

  queueRealtimeSync();
}

function subscribeGlobalRealtimeSync() {
  if (typeof window === "undefined" || !window.Echo) {
    console.warn("[Realtime] Echo not available");
    return;
  }

  globalRealtimeChannel = window.Echo.private("sync.global");
  console.info("[Realtime] Subscribed to sync.global channel");

  globalRealtimeChannel.listen(".realtime.model.changed", (payload) => {
    console.info("[Realtime] Event received:", {
      module: payload?.module,
      action: payload?.action,
      model: payload?.model,
      currentModule: resolveCurrentModule(),
    });

    if (typeof window !== "undefined") {
      window.dispatchEvent(
        new CustomEvent("app:realtime-model-changed", {
          detail: payload || {},
        })
      );
    }

    const actorId = payload?.actor_id ?? null;
    if (actorId && Number(actorId) === Number(page.props?.auth?.user?.id)) {
      console.debug("[Realtime] Ignoring self-generated event");
      return;
    }

    const currentModule = resolveCurrentModule();
    if (!currentModule) {
      console.debug("[Realtime] No current module resolved");
      return;
    }

    if (currentModule !== "dashboard" && payload?.module && payload.module !== currentModule) {
      console.debug("[Realtime] Module mismatch, ignoring", {
        current: currentModule,
        event: payload?.module,
      });
      return;
    }

    if (payload?.__handled) {
      console.debug("[Realtime] Event already handled");
      return;
    }

    console.info("[Realtime] Triggering page reload for module:", currentModule);
    queueRealtimeSync();
  });
}

function unsubscribeGlobalRealtimeSync() {
  if (typeof window !== "undefined" && window.Echo) {
    window.Echo.leave("sync.global");
  }

  globalRealtimeChannel = null;

  if (syncTimerId) {
    window.clearTimeout(syncTimerId);
    syncTimerId = null;
  }
}

const shouldPromptPushActivation = computed(() => {
  if (!page.props.webpush?.enabled) {
    return false;
  }

  if (!pushSupported) {
    return false;
  }

  return pushStatus.value === "not-subscribed";
});

const pushPromptDescription = computed(() => {
  if (browserPermission.value === "denied") {
    return "Notifikasi browser sedang diblokir. Buka pengaturan browser lalu izinkan notifikasi untuk situs ini agar pemberitahuan tetap masuk saat aplikasi tidak dibuka.";
  }

  return "Aktifkan notifikasi browser agar Anda tetap menerima pemberitahuan baru meskipun aplikasi sedang tidak aktif.";
});

async function activatePushNotifications() {
  await requestBrowserPermission();
  await syncPushStatus();

  if (pushStatus.value === "subscribed") {
    pushPromptOpen.value = false;
    $q.notify({
      color: "positive",
      message: "Notifikasi berhasil diaktifkan.",
      position: "top",
    });
  }
}

if (page.props.webpush?.public_key) {
  window.CONFIG = {
    ...(window.CONFIG || {}),
    WEBPUSH_PUBLIC_KEY: page.props.webpush.public_key,
  };
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

  window.setTimeout(() => {
    if (shouldPromptPushActivation.value) {
      pushPromptOpen.value = true;
    }
  }, 900);

  console.info("[Realtime] Initializing global realtime sync");
  subscribeGlobalRealtimeSync();

  if (typeof window !== "undefined") {
    window.addEventListener("app:realtime-notification", handleRealtimeNotification);
  }
});

watch(shouldPromptPushActivation, (nextValue) => {
  if (nextValue) {
    pushPromptOpen.value = true;
  }
});

onBeforeUnmount(() => {
  unsubscribeGlobalRealtimeSync();

  if (typeof window !== "undefined") {
    window.removeEventListener("app:realtime-notification", handleRealtimeNotification);
  }
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
        <div class="row items-center no-wrap q-gutter-xs">
          <q-btn flat round dense icon="notifications" @click="fetchNotifications()">
            <q-badge
              v-if="unreadCount > 0"
              color="negative"
              floating
              rounded
            >
              {{ unreadCount > 99 ? "99+" : unreadCount }}
            </q-badge>
            <q-menu
              v-model="notificationMenuOpen"
              anchor="bottom right"
              self="top right"
              @before-show="fetchNotifications()"
            >
              <q-list class="notification-menu-list">
                <q-item class="notification-menu-head">
                  <q-item-section class="notification-menu-head__title">
                    <q-item-label class="text-weight-bold">Notifikasi</q-item-label>
                    <q-item-label caption>
                      {{ unreadCount }} belum dibaca
                    </q-item-label>
                    <q-item-label caption class="text-blue-grey-7 q-mt-xs">
                      Push: {{ pushStatus === 'subscribed' ? 'Aktif' : 'Belum aktif' }}
                    </q-item-label>
                  </q-item-section>
                  <q-item-section side class="notification-menu-actions">
                    <q-btn
                      v-if="browserPermission !== 'granted' && browserPermission !== 'unsupported'"
                      flat
                      dense
                      no-caps
                      color="primary"
                      label="Aktifkan"
                      @click.stop="requestBrowserPermission()"
                    />
                    <q-btn
                      v-if="unreadCount > 0"
                      flat
                      dense
                      no-caps
                      color="primary"
                      label="Tandai semua"
                      @click.stop="markAllAsRead()"
                    />
                  </q-item-section>
                </q-item>

                <q-separator />

                <q-item v-if="notificationsLoading">
                  <q-item-section>
                    <q-item-label>Memuat notifikasi...</q-item-label>
                  </q-item-section>
                </q-item>

                <q-item v-else-if="notificationItems.length === 0">
                  <q-item-section>
                    <q-item-label>Belum ada notifikasi.</q-item-label>
                  </q-item-section>
                </q-item>

                <q-item
                  v-for="item in notificationItems"
                  :key="item.id"
                  v-close-popup
                  clickable
                  v-ripple
                  class="notification-item"
                  :class="{ 'notification-item--unread': !item.read_at }"
                  @click="showNotificationDetail(item)"
                >
                  <q-item-section avatar>
                    <q-icon :name="item.read_at ? 'notifications_none' : 'notifications_active'" />
                  </q-item-section>
                  <q-item-section>
                    <q-item-label class="text-weight-medium">{{ item.title }}</q-item-label>
                    <q-item-label caption class="notification-message">
                      {{ item.message }}
                    </q-item-label>
                    <q-item-label caption>
                      {{ item.sent_by_name || 'Sistem' }}
                    </q-item-label>
                  </q-item-section>
                </q-item>
              </q-list>
            </q-menu>
          </q-btn>
        </div>
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
              $can('admin.product-knowledge.index')
            "
            v-model="menuGroups.master"
            icon="inventory_2"
            label="Master Data"
            dense-toggle
            expand-separator
            :header-class="$page.url.startsWith('/admin/customers') ||
              $page.url.startsWith('/admin/products') ||
              $page.url.startsWith('/admin/product-categories') ||
              $page.url.startsWith('/admin/product-knowledge')
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
              v-if="canManageInfoNotifications"
              clickable
              v-ripple
              :active="$page.url.startsWith('/admin/settings/notifications')"
              @click="router.get(route('admin.notification.index'))"
            >
              <q-item-section avatar>
                <q-icon name="campaign" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Notifikasi Info</q-item-label>
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

    <q-dialog v-model="pushPromptOpen" persistent>
      <q-card class="push-prompt-card">
        <q-card-section class="row items-center no-wrap q-col-gutter-sm">
          <q-icon name="notifications_active" color="primary" size="26px" />
          <div>
            <div class="text-subtitle1 text-weight-bold">Aktifkan Notifikasi Realtime</div>
            <div class="text-caption text-grey-7 q-mt-xs">
              {{ pushPromptDescription }}
            </div>
          </div>
        </q-card-section>
        <q-separator />
        <q-card-actions align="right">
          <q-btn flat no-caps label="Nanti" color="grey-7" v-close-popup />
          <q-btn
            unelevated
            color="primary"
            no-caps
            label="Aktifkan Sekarang"
            @click="activatePushNotifications"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="notificationDetailOpen">
      <q-card class="notification-detail-card">
        <q-card-section class="q-pb-xs">
          <div class="text-subtitle1 text-weight-bold">
            {{ selectedNotification?.title || "Detail Notifikasi" }}
          </div>
          <div class="text-caption text-grey-7 q-mt-xs">
            {{ selectedNotification?.sent_by_name || "Sistem" }}
            •
            {{ formatNotificationDate(selectedNotification?.created_at) }}
          </div>
        </q-card-section>

        <q-separator />

        <q-card-section>
          <div class="notification-detail-message">
            {{ selectedNotification?.message || "Tidak ada isi pesan." }}
          </div>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right">
          <q-btn flat no-caps label="Tutup" color="grey-7" v-close-popup />
          <q-btn
            v-if="selectedNotification?.url"
            unelevated
            color="primary"
            no-caps
            label="Buka Halaman Terkait"
            @click="openNotificationTarget"
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

.notification-menu-list {
  min-width: 320px;
  max-width: 380px;
}

.notification-menu-head {
  align-items: flex-start;
}

.notification-menu-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  flex-wrap: wrap;
  gap: 4px;
}

.notification-item {
  align-items: flex-start;
}

.notification-item--unread {
  background: #f2f8ff;
}

.notification-message {
  white-space: normal;
  line-height: 1.35;
}

.push-prompt-card {
  width: min(92vw, 460px);
}

.notification-detail-card {
  width: min(92vw, 520px);
}

.notification-detail-message {
  white-space: pre-wrap;
  line-height: 1.5;
}

@media (max-width: 599px) {
  .notification-menu-list {
    min-width: min(92vw, 340px);
    max-width: min(92vw, 340px);
  }

  .notification-menu-head {
    flex-wrap: wrap;
  }

  .notification-menu-head__title {
    min-width: 100%;
  }

  .notification-menu-actions {
    margin-top: 4px;
    width: 100%;
    justify-content: flex-start;
  }
}
</style>
