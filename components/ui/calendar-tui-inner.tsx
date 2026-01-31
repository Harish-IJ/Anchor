"use client";

/**
 * ============================================
 * Toast UI Calendar - Client-Only Component
 * ============================================
 *
 * This component directly renders Toast UI Calendar using the vanilla JS library.
 * It MUST be loaded via dynamic import to avoid SSR issues.
 *
 * @file calendar-tui-inner.tsx
 * @requires @toast-ui/calendar
 *
 * Features:
 * - Week/Month/Day view switching
 * - Event creation via click/drag
 * - Event editing via drag/resize
 * - Event deletion
 * - Themed to match shadcn design system
 *
 * Usage:
 * This component should NOT be imported directly.
 * Use the wrapper in calendar-tui.tsx instead.
 *
 * Architecture:
 * - Uses useEffect to initialize calendar after mount
 * - Calendar instance is created directly in DOM container
 * - Event listeners are attached programmatically
 * - Cleanup happens on unmount
 */

import React, {
  useRef,
  useEffect,
  useState,
  forwardRef,
  useImperativeHandle,
} from "react";

// ============================================
// TYPE DEFINITIONS
// ============================================

/**
 * Calendar Event Interface
 * Represents a single event in the calendar
 *
 * @property id - Unique identifier for the event
 * @property calendarId - ID of the calendar/category this event belongs to
 * @property title - Display title for the event
 * @property start - Start date/time (Date object or ISO string)
 * @property end - End date/time (Date object or ISO string)
 * @property category - Type of event: "time" for timed, "allday" for all-day
 * @property isAllDay - Whether this is an all-day event
 * @property location - Optional location string
 * @property body - Optional description/notes
 * @property state - Busy/Free status for availability
 * @property isReadOnly - If true, event cannot be edited
 * @property color - Text color (CSS color string)
 * @property backgroundColor - Background color (CSS color string)
 * @property borderColor - Border/accent color (CSS color string)
 * @property dragBackgroundColor - Color when dragging (CSS color string)
 */
export interface CalendarEvent {
  id: string;
  calendarId: string;
  title: string;
  start: Date | string;
  end: Date | string;
  category?: "time" | "allday" | "task" | "milestone";
  isAllDay?: boolean;
  location?: string;
  body?: string;
  state?: "Busy" | "Free";
  isReadOnly?: boolean;
  color?: string;
  backgroundColor?: string;
  borderColor?: string;
  dragBackgroundColor?: string;
}

/**
 * Calendar Category Interface
 * Defines a calendar/category for grouping events
 *
 * @property id - Unique identifier matching event.calendarId
 * @property name - Display name for this category
 * @property color - Text color for events in this category
 * @property backgroundColor - Background color for events
 * @property borderColor - Left border accent color
 * @property dragBackgroundColor - Color when dragging events
 */
export interface CalendarCategory {
  id: string;
  name: string;
  color: string;
  backgroundColor: string;
  borderColor: string;
  dragBackgroundColor?: string;
}

/**
 * Component Props Interface
 *
 * @property view - Calendar view mode: "week", "month", or "day"
 * @property events - Array of events to display
 * @property calendars - Array of calendar categories
 * @property onEventClick - Callback when user clicks an event
 * @property onEventCreate - Callback when user creates a new event
 * @property onEventUpdate - Callback when user drags/resizes an event
 * @property onEventDelete - Callback when user deletes an event
 * @property weekStartsOn - First day of week: 0 = Sunday, 1 = Monday
 * @property showWeekend - Whether to show Saturday/Sunday columns
 * @property height - CSS height value for the calendar
 * @property className - Additional CSS classes for the wrapper
 */
export interface TuiCalendarInnerProps {
  view?: "week" | "month" | "day";
  events?: CalendarEvent[];
  calendars?: CalendarCategory[];
  onEventClick?: (event: CalendarEvent) => void;
  onEventCreate?: (eventData: Partial<CalendarEvent>) => void;
  onEventUpdate?: (
    event: CalendarEvent,
    changes: Partial<CalendarEvent>,
  ) => void;
  onEventDelete?: (event: CalendarEvent) => void;
  weekStartsOn?: 0 | 1;
  showWeekend?: boolean;
  height?: string;
  className?: string;
}

// ============================================
// DEFAULT CALENDAR CATEGORIES
// ============================================

/**
 * Default calendar categories with shadcn-compatible colors
 * These use Tailwind color values for consistency with the design system
 *
 * Categories:
 * - work: Violet (#7c3aed) - Primary work tasks
 * - personal: Teal (#14b8a6) - Personal activities
 * - focus: Green (#22c55e) - Focus/deep work sessions
 * - meeting: Yellow (#eab308) - Meetings and calls
 * - reminder: Red (#ef4444) - Important reminders
 */
const defaultCalendars: CalendarCategory[] = [
  {
    id: "work",
    name: "Work",
    color: "#ffffff",
    backgroundColor: "#7c3aed", // violet-600 (matches --primary)
    borderColor: "#7c3aed",
    dragBackgroundColor: "#7c3aed80",
  },
  {
    id: "personal",
    name: "Personal",
    color: "#ffffff",
    backgroundColor: "#14b8a6", // teal-500 (matches --chart-2)
    borderColor: "#14b8a6",
    dragBackgroundColor: "#14b8a680",
  },
  {
    id: "focus",
    name: "Focus Time",
    color: "#ffffff",
    backgroundColor: "#22c55e", // green-500 (matches --chart-3)
    borderColor: "#22c55e",
    dragBackgroundColor: "#22c55e80",
  },
  {
    id: "meeting",
    name: "Meetings",
    color: "#1f2937", // dark text for visibility on yellow
    backgroundColor: "#eab308", // yellow-500 (matches --chart-4)
    borderColor: "#eab308",
    dragBackgroundColor: "#eab30880",
  },
  {
    id: "reminder",
    name: "Reminders",
    color: "#ffffff",
    backgroundColor: "#ef4444", // red-500 (matches --destructive)
    borderColor: "#ef4444",
    dragBackgroundColor: "#ef444480",
  },
];

// ============================================
// THEME CONFIGURATION
// ============================================

/**
 * Get Toast UI Calendar Theme Object based on current color scheme
 *
 * Detects if dark mode is active and returns appropriate theme.
 * Dark mode uses nearly invisible borders for a clean look.
 * Light mode uses subtle gray borders for structure.
 */
const getTheme = () => {
  // Check if we're in a browser and if dark mode is active
  const isDark =
    typeof window !== "undefined" &&
    document.documentElement.classList.contains("dark");

  // Border colors - nearly invisible in dark mode
  const borderColor = isDark ? "rgba(255, 255, 255, 0.03)" : "#e5e7eb";
  const halfHourBorder = isDark ? "rgba(255, 255, 255, 0.02)" : "#e5e7eb";
  const backgroundColor = isDark ? "#0a0a0a" : "#ffffff";
  const textColor = isDark ? "#f5f5f5" : "#1f2937";
  const mutedTextColor = isDark ? "#a1a1aa" : "#6b7280";

  return {
    // Common theme settings (applies to all views)
    common: {
      backgroundColor,
      border: `1px solid ${borderColor}`,
      gridSelection: {
        backgroundColor: "rgba(124, 58, 237, 0.2)",
        border: "1px solid #7c3aed",
      },
      dayName: { color: textColor },
      today: {
        color: "#ffffff",
        backgroundColor: "#7c3aed",
      },
      saturday: { color: mutedTextColor },
      sunday: { color: "#ef4444" },
    },

    // Week view specific settings
    week: {
      timeGridLeft: {
        width: "60px",
        backgroundColor,
        borderRight: `1px solid ${borderColor}`,
      },
      dayGridLeft: { borderRight: `1px solid ${borderColor}` },
      today: { backgroundColor: "rgba(124, 58, 237, 0.05)" },
      nowIndicatorLabel: { color: "#7c3aed" },
      nowIndicatorBullet: { backgroundColor: "#7c3aed" },
      nowIndicatorToday: { border: "1px solid #7c3aed" },
      timeGrid: { borderRight: `1px solid ${borderColor}` },
      timeGridHalfHourLine: { borderBottom: `1px dotted ${halfHourBorder}` },
      timeGridHourLine: { borderBottom: `1px solid ${borderColor}` },
    },

    // Month view specific settings
    month: {
      dayExceptThisMonth: { color: mutedTextColor },
    },
  };
};

// ============================================
// CALENDAR COMPONENT
// ============================================

/**
 * Inner Calendar Component
 *
 * This component initializes and manages a Toast UI Calendar instance.
 * It handles the lifecycle (create/update/destroy) and exposes methods
 * via useImperativeHandle for parent component control.
 *
 * @param props - Component props (see TuiCalendarInnerProps)
 * @param ref - ForwardRef for accessing calendar instance
 * @returns React component rendering the calendar
 */
const TuiCalendarInner = forwardRef<unknown, TuiCalendarInnerProps>(
  function TuiCalendarInner(
    {
      view = "week",
      events = [],
      calendars = defaultCalendars,
      onEventClick,
      onEventCreate,
      onEventUpdate,
      onEventDelete,
      weekStartsOn = 1,
      showWeekend = true,
      height = "600px",
      className = "",
    },
    ref,
  ) {
    // DOM container for the calendar
    const containerRef = useRef<HTMLDivElement>(null);

    // Toast UI Calendar instance
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const calendarInstanceRef = useRef<any>(null);

    // Loading state for showing placeholder
    const [isLoaded, setIsLoaded] = useState(false);

    // ============================================
    // IMPERATIVE HANDLE
    // ============================================

    /**
     * Expose calendar instance to parent component
     * Parent can call ref.current.getInstance() to access
     * the Toast UI Calendar instance for direct manipulation
     */
    useImperativeHandle(ref, () => ({
      getInstance: () => calendarInstanceRef.current,
    }));

    // ============================================
    // CALENDAR INITIALIZATION
    // ============================================

    /**
     * Initialize the calendar on component mount
     *
     * This effect:
     * 1. Dynamically imports Toast UI Calendar (avoids SSR issues)
     * 2. Creates the calendar instance in the container
     * 3. Configures options, theme, and calendars
     * 4. Attaches event handlers
     * 5. Adds initial events
     * 6. Handles cleanup on unmount
     */
    useEffect(() => {
      if (!containerRef.current) return;

      let mounted = true;

      const initCalendar = async () => {
        try {
          // Dynamically import the vanilla calendar library
          // This import only happens client-side, after mount
          // @ts-expect-error - Toast UI Calendar types don't export correctly from package.json
          const ToastUICalendar = (await import("@toast-ui/calendar")).default;

          // Import CSS styles
          // @ts-expect-error - CSS import doesn't have type declarations
          await import("@toast-ui/calendar/dist/toastui-calendar.min.css");

          // Ensure component is still mounted
          if (!mounted || !containerRef.current) return;

          // Create the calendar instance with dynamic theme based on color scheme
          const calendar = new ToastUICalendar(containerRef.current, {
            defaultView: view,
            useFormPopup: false, // We'll handle forms ourselves
            useDetailPopup: false, // We'll handle details ourselves
            usageStatistics: false, // Disable analytics
            theme: getTheme(), // Dynamic theme based on dark/light mode

            // Week view configuration
            week: {
              startDayOfWeek: weekStartsOn,
              dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
              narrowWeekend: !showWeekend,
              workweek: !showWeekend,
              showNowIndicator: true,
              showTimezoneCollapseButton: false,
              hourStart: 6,
              hourEnd: 22,
              eventView: ["time"],
              taskView: false,
            },

            // Month view configuration
            month: {
              startDayOfWeek: weekStartsOn,
              dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
              narrowWeekend: !showWeekend,
            },

            // Enable grid selection for event creation
            gridSelection: {
              enableDblClick: true,
              enableClick: true,
            },

            // Timezone configuration
            timezone: {
              zones: [
                {
                  timezoneName:
                    Intl.DateTimeFormat().resolvedOptions().timeZone,
                  displayLabel: "Local",
                },
              ],
            },

            // Calendar categories
            calendars,
          });

          // ============================================
          // EVENT HANDLERS
          // ============================================

          // Handle click on existing event
          if (onEventClick) {
            calendar.on("clickEvent", (eventInfo: { event: CalendarEvent }) => {
              onEventClick(eventInfo.event);
            });
          }

          // Handle event creation (user selects time slot)
          if (onEventCreate) {
            calendar.on(
              "selectDateTime",
              (selectionInfo: {
                start: Date;
                end: Date;
                isAllDay: boolean;
              }) => {
                onEventCreate({
                  start: selectionInfo.start,
                  end: selectionInfo.end,
                  isAllDay: selectionInfo.isAllDay,
                });
                // Clear selection after handling
                calendar.clearGridSelections();
              },
            );
          }

          // Handle event update (drag/resize)
          if (onEventUpdate) {
            calendar.on(
              "beforeUpdateEvent",
              (updateInfo: {
                event: CalendarEvent;
                changes: Partial<CalendarEvent>;
              }) => {
                onEventUpdate(updateInfo.event, updateInfo.changes);
              },
            );
          }

          // Handle event deletion
          if (onEventDelete) {
            calendar.on(
              "beforeDeleteEvent",
              (deleteInfo: { event: CalendarEvent }) => {
                onEventDelete(deleteInfo.event);
              },
            );
          }

          // Add initial events
          if (events.length > 0) {
            calendar.createEvents(events);
          }

          // Store instance and mark as loaded
          calendarInstanceRef.current = calendar;
          setIsLoaded(true);
        } catch (error) {
          console.error("Failed to load Toast UI Calendar:", error);
        }
      };

      initCalendar();

      // Cleanup on unmount
      return () => {
        mounted = false;
        if (calendarInstanceRef.current) {
          calendarInstanceRef.current.destroy();
          calendarInstanceRef.current = null;
        }
      };
      // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []); // Only run once on mount

    // ============================================
    // EVENT UPDATES
    // ============================================

    /**
     * Update events when props change
     * Clears existing events and recreates with new data
     */
    useEffect(() => {
      if (!calendarInstanceRef.current || !isLoaded) return;

      calendarInstanceRef.current.clear();
      if (events.length > 0) {
        calendarInstanceRef.current.createEvents(events);
      }
    }, [events, isLoaded]);

    // ============================================
    // VIEW UPDATES
    // ============================================

    /**
     * Update view when props change
     * Switches between week/month/day views
     */
    useEffect(() => {
      if (!calendarInstanceRef.current || !isLoaded) return;
      calendarInstanceRef.current.changeView(view);
    }, [view, isLoaded]);

    // ============================================
    // RENDER
    // ============================================

    return (
      <div className={`tui-calendar-wrapper ${className}`}>
        {/* Calendar container - Toast UI mounts here */}
        <div
          ref={containerRef}
          style={{ height, minHeight: "500px" }}
          className={
            !isLoaded
              ? "bg-card border rounded-xl animate-pulse flex items-center justify-center"
              : ""
          }>
          {/* Loading placeholder */}
          {!isLoaded && (
            <span className='text-muted-foreground'>Loading calendar...</span>
          )}
        </div>
      </div>
    );
  },
);

export default TuiCalendarInner;
