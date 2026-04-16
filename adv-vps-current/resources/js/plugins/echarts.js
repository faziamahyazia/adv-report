import { use } from "echarts/core";
import { CanvasRenderer } from "echarts/renderers";
import {
  BarChart,
  LineChart,
  PieChart,
  RadarChart,
} from "echarts/charts";
import {
  GridComponent,
  TooltipComponent,
  LegendComponent,
  TitleComponent,
  DatasetComponent,
  TransformComponent,
  RadarComponent,
} from "echarts/components";

// Explicit ECharts module registration for production-safe tree-shaking.
use([
  CanvasRenderer,
  BarChart,
  LineChart,
  PieChart,
  RadarChart,
  GridComponent,
  TooltipComponent,
  LegendComponent,
  TitleComponent,
  DatasetComponent,
  TransformComponent,
  RadarComponent,
]);
