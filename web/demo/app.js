import { evaluate } from "./assets/bridge.js";

const form = document.querySelector("#hours-form");
const expressionInput = document.querySelector("#expression");
const datetimeInput = document.querySelector("#datetime");
const calendarInput = document.querySelector("#china-calendar");
const calendarStatus = document.querySelector("#calendar-status");
const result = document.querySelector("#result");
const nextChange = document.querySelector("#next-change");

let chineseCalendar = null;

function localDateTimeValue(date = new Date()) {
  const pad = (part) => String(part).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function renderResult(text) {
  const [stateLine, ...detailLines] = text.split("\n");
  result.textContent = stateLine;
  result.classList.remove("is-open", "is-closed", "is-error");
  if (stateLine === "营业中") result.classList.add("is-open");
  else if (stateLine === "已关闭") result.classList.add("is-closed");
  else result.classList.add("is-error");
  nextChange.textContent = detailLines
    .map((line) => line.replace(/^下次状态变化：/, ""))
    .join(" ") || "—";
}

function runEvaluation() {
  if (!form.reportValidity()) return;
  const calendar = calendarInput.checked ? chineseCalendar : null;
  const publicHolidays = calendar?.public_holidays.join(",") ?? "";
  const schoolHolidays = calendar?.school_holidays.join(",") ?? "";
  renderResult(evaluate(
    expressionInput.value,
    datetimeInput.value,
    publicHolidays,
    schoolHolidays,
  ));
}

datetimeInput.value = localDateTimeValue();

for (const chip of document.querySelectorAll("[data-expression]")) {
  chip.addEventListener("click", () => {
    expressionInput.value = chip.dataset.expression;
    runEvaluation();
  });
}

form.addEventListener("submit", (event) => {
  event.preventDefault();
  runEvaluation();
});

calendarInput.addEventListener("change", runEvaluation);

try {
  const response = await fetch("./china-2026-holidays.json");
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  chineseCalendar = await response.json();
  calendarStatus.textContent = `${chineseCalendar.public_holidays.length} 个放假日期`;
  runEvaluation();
} catch {
  calendarInput.checked = false;
  calendarInput.disabled = true;
  calendarStatus.textContent = "示例日历未加载；PH/SH 不匹配";
  runEvaluation();
}
