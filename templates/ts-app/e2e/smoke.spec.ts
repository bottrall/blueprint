import { expect, test } from "@playwright/test";

test("opens at home", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("heading", { level: 1 })).toHaveText("{{name}}");
});

test("counts across a reload", async ({ page }) => {
  await page.goto("/counter");
  await page.getByRole("button", { name: "Add one" }).click();
  await page.reload();
  await expect(page.getByRole("status", { name: "Count" })).toHaveText("1");
});
