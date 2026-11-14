export function parse(text: string): any {
  return JSON.parse(text) as unknown;
}
