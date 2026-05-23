"use client";

import { useState } from "react";
import type { Template, TemplateField } from "@/types";

interface ApplicationFormProps {
  template: Template;
  prefilledData: Record<string, unknown>;
  comment: string | null;
}

export default function ApplicationForm({
  template,
  prefilledData,
  comment,
}: ApplicationFormProps) {
  const [formData] = useState<Record<string, string | number>>(() => {
    const initial: Record<string, string | number> = {};
    for (const field of template.fields) {
      const val = prefilledData[field.id];
      initial[field.id] = val !== undefined && val !== null ? String(val) : "";
    }
    return initial;
  });
  const [edits, setEdits] = useState<Record<string, string | number>>({});
  const [submitted, setSubmitted] = useState(false);

  function getFieldValue(fieldId: string): string | number {
    if (fieldId in edits) return edits[fieldId];
    return formData[fieldId] ?? "";
  }

  function handleChange(fieldId: string, value: string | number) {
    setEdits((prev) => ({ ...prev, [fieldId]: value }));
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitted(true);
  }

  if (submitted) {
    const allFields = { ...formData, ...edits };
    return (
      <div className="bg-green-50 border border-green-200 rounded-lg p-6 text-center">
        <div className="text-green-600 text-4xl mb-2">✓</div>
        <h3 className="text-lg font-semibold text-green-800 mb-1">
          Заявка отправлена
        </h3>
        <p className="text-green-600 text-sm">
          Ваша заявка на «{template.name}» успешно создана и направлена на
          рассмотрение.
        </p>
        <div className="mt-4 text-left bg-white rounded-md p-4 border border-green-100">
          {template.fields.map((field) => (
            <div key={field.id} className="flex justify-between py-1 text-sm">
              <span className="text-gray-500">{field.label}:</span>
              <span className="text-gray-800 font-medium">
                {String(allFields[field.id] || "—")}
              </span>
            </div>
          ))}
          {comment && (
            <div className="flex justify-between py-1 text-sm border-t border-gray-100 mt-1 pt-2">
              <span className="text-gray-500">Комментарий:</span>
              <span className="text-gray-800 font-medium">{comment}</span>
            </div>
          )}
        </div>
      </div>
    );
  }

  function renderField(field: TemplateField) {
    const value = getFieldValue(field.id);

    if (field.type === "select" && field.options) {
      return (
        <select
          value={String(value)}
          onChange={(e) => handleChange(field.id, e.target.value)}
          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900 text-sm"
        >
          <option value="">Выберите...</option>
          {field.options.map((opt) => (
            <option key={opt} value={opt}>
              {opt}
            </option>
          ))}
        </select>
      );
    }

    if (field.type === "number") {
      return (
        <input
          type="number"
          value={value === "" ? "" : String(value)}
          onChange={(e) =>
            handleChange(
              field.id,
              e.target.value === "" ? "" : Number(e.target.value)
            )
          }
          min={1}
          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900 text-sm"
        />
      );
    }

    return (
      <input
        type="text"
        value={String(value)}
        onChange={(e) => handleChange(field.id, e.target.value)}
        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900 text-sm"
      />
    );
  }

  const isFilled = (fieldId: string) =>
    prefilledData[fieldId] !== undefined && prefilledData[fieldId] !== null;

  return (
    <form
      onSubmit={handleSubmit}
      className="bg-white border border-gray-200 rounded-lg overflow-hidden"
    >
      <div className="bg-gray-50 px-4 py-3 border-b border-gray-200">
        <h3 className="font-semibold text-gray-800 uppercase text-sm tracking-wide">
          {template.name}
        </h3>
        {template.description && (
          <p className="text-xs text-gray-500 mt-1">{template.description}</p>
        )}
      </div>
      <div className="p-4 space-y-3">
        {template.fields.map((field) => (
          <div key={field.id}>
            <label className="flex items-center gap-2 text-sm font-medium text-gray-700 mb-1">
              {field.label}
              {isFilled(field.id) && (
                <span className="text-green-600 text-xs">авто</span>
              )}
            </label>
            {renderField(field)}
          </div>
        ))}
      </div>
      {comment && (
        <div className="px-4 pb-3">
          <p className="text-xs text-gray-500">Комментарий: {comment}</p>
        </div>
      )}
      <div className="px-4 pb-4">
        <button
          type="submit"
          className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 font-medium text-sm"
        >
          Отправить заявку
        </button>
      </div>
    </form>
  );
}
