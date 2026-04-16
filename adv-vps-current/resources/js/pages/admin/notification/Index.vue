<script setup>
import { computed, nextTick, ref, watch } from "vue";
import { useForm, usePage } from "@inertiajs/vue3";
import { useQuasar } from "quasar";

const page = usePage();
const $q = useQuasar();
const targetModeOptions = [
  { label: "Semua user aktif", value: "all" },
  { label: "Berdasarkan role", value: "role" },
  { label: "Pilih user tertentu", value: "users" },
];

const form = useForm({
  target_mode: "role",
  target_role: "bs",
  user_ids: [],
  title: "",
  message: "",
  url: "/admin/dashboard",
});

const targetModeField = ref(null);
const targetRoleField = ref(null);
const userIdsField = ref(null);
const titleField = ref(null);
const messageField = ref(null);
const urlField = ref(null);

const canPickRole = computed(() => form.target_mode === "role");
const canPickUsers = computed(() => form.target_mode === "users");
const isCompact = computed(() => $q.screen.lt.md);

watch(
  () => form.target_mode,
  (nextMode) => {
    if (nextMode !== "role") {
      form.target_role = null;
      delete form.errors.target_role;
    }

    if (nextMode !== "users") {
      form.user_ids = [];
      delete form.errors.user_ids;
    }

    if (nextMode === "role" && !form.target_role) {
      form.target_role = "bs";
    }
  }
);

function focusField(fieldRef) {
  const component = fieldRef?.value;

  if (!component) {
    return;
  }

  const targetElement = component.$el || component;

  if (typeof component.focus === "function") {
    component.focus();
  } else {
    const input = targetElement?.querySelector?.("input, textarea, [tabindex]");
    input?.focus?.();
  }

  targetElement?.scrollIntoView?.({
    behavior: "smooth",
    block: "center",
  });
}

async function focusFirstErrorField() {
  await nextTick();

  const fields = [
    ["target_mode", targetModeField],
    ["target_role", targetRoleField],
    ["user_ids", userIdsField],
    ["title", titleField],
    ["message", messageField],
    ["url", urlField],
  ];

  for (const [key, fieldRef] of fields) {
    if (!form.errors[key]) {
      continue;
    }

    if (key === "target_role" && !canPickRole.value) {
      continue;
    }

    if (key === "user_ids" && !canPickUsers.value) {
      continue;
    }

    focusField(fieldRef);
    break;
  }
}

function submit() {
  form.post(route("admin.notification.store"), {
    preserveScroll: true,
    onSuccess: (responsePage) => {
      const flash = responsePage?.props?.flash || {};

      if (flash.error) {
        $q.notify({
          color: "negative",
          message: flash.error,
          position: "top",
        });
        return;
      }

      $q.notify({
        color: flash.warning ? "warning" : "positive",
        message: flash.success || flash.warning || "Pesan terkirim.",
        position: "top",
      });

      if (!flash.warning) {
        form.reset("title", "message");
      }
    },
    onError: () => {
      $q.notify({
        color: "negative",
        message:
          form.errors.target_role ||
          form.errors.user_ids ||
          form.errors.title ||
          form.errors.message ||
          "Pesan gagal dikirim.",
        position: "top",
      });

      focusFirstErrorField();
    },
  });
}
</script>

<template>
  <authenticated-layout>
    <template #title>Pengumuman BS</template>

    <div class="notification-page">
      <q-card flat bordered class="notification-hero q-mb-md">
        <q-card-section>
          <div class="text-overline text-blue-grey-7">Pusat Pengumuman</div>
          <div class="text-h6 text-weight-bold">Kirim informasi ke user</div>
          <div class="text-caption text-grey-7 q-mt-xs">
            Pengumuman akan masuk ke inbox notifikasi user di aplikasi.
          </div>
        </q-card-section>
      </q-card>

      <q-form @submit.prevent="submit">
        <q-card flat bordered class="notification-form-card">
          <q-card-section class="notification-form-body">
            <div class="form-grid-target row q-col-gutter-md">
              <div class="col-12 col-md-4">
                <q-select
                  ref="targetModeField"
                  v-model="form.target_mode"
                  outlined
                  emit-value
                  map-options
                  :dense="isCompact"
                  label="Target Pengiriman"
                  :options="targetModeOptions"
                  :error="!!form.errors.target_mode"
                  :error-message="form.errors.target_mode"
                />
              </div>

              <div v-if="canPickRole" class="col-12 col-md-4">
                <q-select
                  ref="targetRoleField"
                  v-model="form.target_role"
                  outlined
                  emit-value
                  map-options
                  :dense="isCompact"
                  label="Role Tujuan"
                  :options="page.props.recipient_role_options"
                  :error="!!form.errors.target_role"
                  :error-message="form.errors.target_role"
                />
              </div>

              <div v-if="canPickUsers" class="col-12 col-md-8">
                <q-select
                  ref="userIdsField"
                  v-model="form.user_ids"
                  outlined
                  emit-value
                  map-options
                  multiple
                  use-input
                  use-chips
                  :dense="isCompact"
                  input-debounce="0"
                  label="User Tujuan"
                  :options="page.props.recipient_user_options"
                  option-label="label"
                  option-value="value"
                  option-disable="disabled"
                  :error="!!form.errors.user_ids"
                  :error-message="form.errors.user_ids"
                >
                  <template #option="scope">
                    <q-item v-bind="scope.itemProps">
                      <q-item-section>
                        <q-item-label>{{ scope.opt.label }}</q-item-label>
                        <q-item-label caption>{{ scope.opt.caption }}</q-item-label>
                      </q-item-section>
                    </q-item>
                  </template>
                </q-select>
              </div>
            </div>

            <q-input
              ref="titleField"
              v-model="form.title"
              outlined
              :dense="isCompact"
              label="Judul Pengumuman"
              maxlength="120"
              :error="!!form.errors.title"
              :error-message="form.errors.title"
            />

            <q-input
              ref="messageField"
              v-model="form.message"
              type="textarea"
              autogrow
              outlined
              :dense="isCompact"
              rows="4"
              label="Isi Pengumuman"
              maxlength="2000"
              :error="!!form.errors.message"
              :error-message="form.errors.message"
            />

            <q-input
              ref="urlField"
              v-model="form.url"
              outlined
              :dense="isCompact"
              label="URL tujuan saat notifikasi dibuka"
              hint="Boleh internal path seperti /admin/complaints atau URL lengkap."
              :error="!!form.errors.url"
              :error-message="form.errors.url"
            />
          </q-card-section>

          <q-separator />

          <q-card-actions class="notification-actions" align="right">
            <q-btn
              color="primary"
              icon="campaign"
              label="Kirim Pengumuman"
              type="submit"
              unelevated
              no-caps
              :loading="form.processing"
            />
          </q-card-actions>
        </q-card>
      </q-form>
    </div>
  </authenticated-layout>
</template>

<style scoped>
.notification-page {
  width: 100%;
  max-width: none;
  margin: 0;
  padding: 12px 14px;
}

.notification-hero {
  width: 100%;
  border-radius: 14px;
  border-color: #d3dfec;
  background:
    radial-gradient(circle at 95% 0%, rgba(37, 99, 235, 0.12), rgba(37, 99, 235, 0)),
    linear-gradient(155deg, #f8fbff 0%, #eef5ff 58%, #f8fcff 100%);
}

.notification-form-card {
  width: 100%;
  border-radius: 14px;
  border-color: #dbe5ef;
}

.notification-form-body {
  display: grid;
  gap: 14px;
}

.form-grid-target {
  margin-bottom: 2px;
}

.notification-actions {
  padding: 12px 16px 14px;
}

@media (min-width: 1024px) {
  .notification-page {
    padding: 14px 18px;
  }

  .notification-form-body {
    gap: 16px;
  }
}

@media (max-width: 599px) {
  .notification-page {
    padding: 8px;
  }

  .notification-actions {
    justify-content: stretch;
  }

  .notification-actions .q-btn {
    width: 100%;
  }
}
</style>
