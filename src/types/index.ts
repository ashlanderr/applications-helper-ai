export interface TemplateField {
  id: string;
  label: string;
  type: "text" | "select" | "number";
  options?: string[];
}

export interface Template {
  id: string;
  name: string;
  description: string;
  fields: TemplateField[];
}
