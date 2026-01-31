"use client";

/**
 * ============================================
 * Toast UI Calendar - Wrapper Component
 * ============================================
 *
 * SSR-safe wrapper for Toast UI Calendar.
 * Uses Next.js dynamic import to load the calendar client-side only.
 *
 * @file calendar-tui.tsx
 *
 * Usage:
 * ```tsx
 * import { TuiCalendar, sampleEvents } from "@/components/ui/calendar-tui";
 *
 * function MyComponent() {
 *   const calendarRef = useRef(null);
 *
 *   return (
 *     <TuiCalendar
 *       view="week"
 *       events={sampleEvents}
 *       onEventClick={(e) => console.log(e)}
 *       calendarRef={calendarRef}
 *     />
 *   );
 * }
 * ```
 *
 * Architecture:
 * - This file exports the public API
 * - calendar-tui-inner.tsx contains the actual implementation
 * - Dynamic import prevents SSR issues with Toast UI Calendar
 */

import React from "react";
import dynamic from "next/dynamic";

// ============================================
// TYPE RE-EXPORTS
// ============================================

/**
 * Re-export types from inner component for public API
 */
export type {
  CalendarEvent,
  CalendarCategory,
  TuiCalendarInnerProps as TuiCalendarProps,
} from "./calendar-tui-inner";

// ============================================
// DYNAMIC IMPORT
// ============================================

/**
 * Dynamically import the calendar component
 *
 * ssr: false ensures the component only loads client-side
 * This prevents the ReactCurrentDispatcher error from Toast UI
 *
 * The loading component shows while the calendar is being loaded
 */
const TuiCalendarInner = dynamic(() => import("./calendar-tui-inner"), {
  ssr: false,
  loading: () => (
    <div className='bg-card border rounded-xl animate-pulse min-h-[500px] flex items-center justify-center'>
      <span className='text-muted-foreground'>Loading calendar...</span>
    </div>
  ),
});

// ============================================
// SAMPLE EVENTS
// ============================================

/**
 * Sample events for demonstration
 *
 * These events showcase different calendar categories:
 * - work: Team Standup (violet)
 * - focus: Deep Work Session (green)
 * - meeting: Client Call (yellow)
 * - personal: Gym (teal)
 * - reminder: Submit Report (red)
 *
 * Note: Uses new Date() for current day, adjust as needed
 */
export const sampleEvents = [
  {
    id: "1",
    calendarId: "work",
    title: "Team Standup",
    start: new Date(new Date().setHours(9, 0, 0, 0)),
    end: new Date(new Date().setHours(9, 30, 0, 0)),
    category: "time" as const,
    location: "Conference Room A",
  },
  {
    id: "2",
    calendarId: "focus",
    title: "Deep Work Session",
    start: new Date(new Date().setHours(10, 0, 0, 0)),
    end: new Date(new Date().setHours(12, 0, 0, 0)),
    category: "time" as const,
    body: "Focus on feature development",
  },
  {
    id: "3",
    calendarId: "meeting",
    title: "Client Call",
    start: new Date(new Date().setHours(14, 0, 0, 0)),
    end: new Date(new Date().setHours(15, 0, 0, 0)),
    category: "time" as const,
    location: "Zoom",
  },
  {
    id: "4",
    calendarId: "personal",
    title: "Gym",
    start: new Date(new Date().setHours(18, 0, 0, 0)),
    end: new Date(new Date().setHours(19, 0, 0, 0)),
    category: "time" as const,
  },
  {
    id: "5",
    calendarId: "reminder",
    title: "Submit Report",
    start: new Date(new Date().setHours(17, 0, 0, 0)),
    end: new Date(new Date().setHours(17, 30, 0, 0)),
    category: "task" as const,
  },
];

// ============================================
// WRAPPER COMPONENT PROPS
// ============================================

// Import CalendarEvent and CalendarCategory from inner for local use
import type {
  CalendarEvent as InnerCalendarEvent,
  CalendarCategory as InnerCalendarCategory,
} from "./calendar-tui-inner";

/**
 * Props for the TuiCalendar wrapper component
 * Uses the same types as the inner component for consistency
 *
 * @property view - Calendar view: "week", "month", or "day"
 * @property events - Array of calendar events to display
 * @property calendars - Calendar categories for event grouping
 * @property onEventClick - Handler when user clicks an event
 * @property onEventCreate - Handler when user creates a new event
 * @property onEventUpdate - Handler when user drags/resizes an event
 * @property onEventDelete - Handler when user deletes an event
 * @property weekStartsOn - Week start day: 0 = Sunday, 1 = Monday
 * @property showWeekend - Whether to show weekend columns
 * @property height - CSS height value for the calendar
 * @property className - Additional CSS classes
 * @property calendarRef - Ref to access calendar instance methods
 */
interface TuiCalendarWrapperProps {
  view?: "week" | "month" | "day";
  events?: InnerCalendarEvent[];
  calendars?: InnerCalendarCategory[];
  onEventClick?: (event: InnerCalendarEvent) => void;
  onEventCreate?: (eventData: Partial<InnerCalendarEvent>) => void;
  onEventUpdate?: (
    event: InnerCalendarEvent,
    changes: Partial<InnerCalendarEvent>,
  ) => void;
  onEventDelete?: (event: InnerCalendarEvent) => void;
  weekStartsOn?: 0 | 1;
  showWeekend?: boolean;
  height?: string;
  className?: string;
  calendarRef?: React.RefObject<CalendarInstanceRef | null>;
}

// ============================================
// CALENDAR INSTANCE REF TYPE
// ============================================

/**
 * Type for calendar ref that exposes getInstance method
 */
export interface CalendarInstanceRef {
  getInstance: () => unknown;
}

// ============================================
// WRAPPER COMPONENT
// ============================================

/**
 * TuiCalendar - Main exported component
 *
 * This is the public API for using Toast UI Calendar.
 * It wraps the dynamically imported inner component and
 * provides a clean interface for calendar functionality.
 *
 * @param props - Component props (see TuiCalendarWrapperProps)
 * @returns React component with the calendar
 *
 * @example
 * ```tsx
 * <TuiCalendar
 *   view="week"
 *   events={myEvents}
 *   onEventClick={(e) => setSelected(e)}
 *   height="600px"
 * />
 * ```
 */
export function TuiCalendar({
  calendarRef,
  ...props
}: TuiCalendarWrapperProps) {
  return <TuiCalendarInner ref={calendarRef} {...props} />;
}

// ============================================
// UTILITY FUNCTIONS
// ============================================

/**
 * Get the Toast UI Calendar instance from a ref
 *
 * Use this to access the underlying calendar API for
 * operations like navigation, rendering, etc.
 *
 * @param calendarRef - Ref to the calendar component
 * @returns The Toast UI Calendar instance or undefined
 *
 * @example
 * ```tsx
 * const instance = getCalendarInstance(calendarRef);
 * instance?.today();
 * ```
 */
export function getCalendarInstance(
  calendarRef: React.RefObject<CalendarInstanceRef | null>,
) {
  return calendarRef.current?.getInstance?.();
}

/**
 * Navigate calendar to today's date
 *
 * @param calendarRef - Ref to the calendar component
 *
 * @example
 * ```tsx
 * <button onClick={() => goToToday(calendarRef)}>Today</button>
 * ```
 */
export function goToToday(
  calendarRef: React.RefObject<CalendarInstanceRef | null>,
) {
  const instance = getCalendarInstance(calendarRef);
  if (instance && typeof instance === "object" && "today" in instance) {
    (instance as { today: () => void }).today();
  }
}

/**
 * Navigate calendar to previous period
 *
 * Goes back one day/week/month depending on current view
 *
 * @param calendarRef - Ref to the calendar component
 *
 * @example
 * ```tsx
 * <button onClick={() => goToPrev(calendarRef)}>← Previous</button>
 * ```
 */
export function goToPrev(
  calendarRef: React.RefObject<CalendarInstanceRef | null>,
) {
  const instance = getCalendarInstance(calendarRef);
  if (instance && typeof instance === "object" && "prev" in instance) {
    (instance as { prev: () => void }).prev();
  }
}

/**
 * Navigate calendar to next period
 *
 * Goes forward one day/week/month depending on current view
 *
 * @param calendarRef - Ref to the calendar component
 *
 * @example
 * ```tsx
 * <button onClick={() => goToNext(calendarRef)}>Next →</button>
 * ```
 */
export function goToNext(
  calendarRef: React.RefObject<CalendarInstanceRef | null>,
) {
  const instance = getCalendarInstance(calendarRef);
  if (instance && typeof instance === "object" && "next" in instance) {
    (instance as { next: () => void }).next();
  }
}

/**
 * Change the calendar view mode
 *
 * @param calendarRef - Ref to the calendar component
 * @param view - Target view: "week", "month", or "day"
 *
 * @example
 * ```tsx
 * <button onClick={() => changeView(calendarRef, "month")}>Month View</button>
 * ```
 */
export function changeView(
  calendarRef: React.RefObject<CalendarInstanceRef | null>,
  view: "week" | "month" | "day",
) {
  const instance = getCalendarInstance(calendarRef);
  if (instance && typeof instance === "object" && "changeView" in instance) {
    (instance as { changeView: (v: string) => void }).changeView(view);
  }
}

/**
 * Get the current date range displayed in the calendar
 *
 * @param calendarRef - Ref to the calendar component
 * @returns Object with start and end dates, or null
 *
 * @example
 * ```tsx
 * const range = getDateRange(calendarRef);
 * console.log(`Showing ${range?.start} to ${range?.end}`);
 * ```
 */
export function getDateRange(
  calendarRef: React.RefObject<CalendarInstanceRef | null>,
): { start: Date; end: Date } | null {
  const instance = getCalendarInstance(calendarRef);
  if (
    instance &&
    typeof instance === "object" &&
    "getDateRangeStart" in instance &&
    "getDateRangeEnd" in instance
  ) {
    const typedInstance = instance as {
      getDateRangeStart: () => { toDate: () => Date };
      getDateRangeEnd: () => { toDate: () => Date };
    };
    return {
      start: typedInstance.getDateRangeStart().toDate(),
      end: typedInstance.getDateRangeEnd().toDate(),
    };
  }
  return null;
}

// Default export for convenience
export default TuiCalendar;
