"use client";

/**
 * Schedule Page
 *
 * Features:
 * - Toast UI Calendar integration for week/month/day views
 * - Tasks panel on the right side
 * - Toggleable timer widget
 * - Event creation, editing, and management
 */

import { useState, useCallback, useRef } from "react";
import { Timer, Plus, ChevronLeft, ChevronRight, Clock } from "lucide-react";
import Layout from "@/components/layout";
import { cn } from "@/lib/utils";
import {
  TuiCalendar,
  sampleEvents,
  goToToday,
  goToPrev,
  goToNext,
  changeView,
  type CalendarInstanceRef,
  type CalendarEvent,
} from "@/components/ui/calendar-tui";

// ============================================
// COMPONENT
// ============================================

export default function SchedulePage() {
  // Calendar ref - typed for proper TypeScript support
  const calendarRef = useRef<CalendarInstanceRef | null>(null);

  // View state: week, month, or day
  const [currentView, setCurrentView] = useState<"week" | "month" | "day">(
    "week",
  );

  // Current date for header display
  const [currentDate, setCurrentDate] = useState(new Date());

  // Events state - explicitly typed as CalendarEvent[] for proper type inference
  const [events, setEvents] = useState<CalendarEvent[]>(
    sampleEvents as CalendarEvent[],
  );

  // Timer visibility state
  const [showTimer, setShowTimer] = useState(false);

  // ============================================
  // CALENDAR NAVIGATION HANDLERS
  // ============================================

  /**
   * Navigate to previous period
   */
  const handlePrev = useCallback(() => {
    goToPrev(calendarRef);
    // Update displayed date
    const newDate = new Date(currentDate);
    if (currentView === "month") {
      newDate.setMonth(newDate.getMonth() - 1);
    } else if (currentView === "week") {
      newDate.setDate(newDate.getDate() - 7);
    } else {
      newDate.setDate(newDate.getDate() - 1);
    }
    setCurrentDate(newDate);
  }, [currentDate, currentView]);

  /**
   * Navigate to next period
   */
  const handleNext = useCallback(() => {
    goToNext(calendarRef);
    // Update displayed date
    const newDate = new Date(currentDate);
    if (currentView === "month") {
      newDate.setMonth(newDate.getMonth() + 1);
    } else if (currentView === "week") {
      newDate.setDate(newDate.getDate() + 7);
    } else {
      newDate.setDate(newDate.getDate() + 1);
    }
    setCurrentDate(newDate);
  }, [currentDate, currentView]);

  /**
   * Navigate to today
   */
  const handleToday = useCallback(() => {
    goToToday(calendarRef);
    setCurrentDate(new Date());
  }, []);

  /**
   * Change calendar view mode
   */
  const handleViewChange = useCallback((view: "week" | "month" | "day") => {
    setCurrentView(view);
    changeView(calendarRef, view);
  }, []);

  // ============================================
  // EVENT HANDLERS
  // ============================================

  /**
   * Handle clicking on an existing event
   */
  const handleEventClick = useCallback((event: CalendarEvent) => {
    console.log("Event clicked:", event);
    // TODO: Open event detail/edit modal
  }, []);

  /**
   * Handle creating a new event by selecting time slots
   */
  const handleEventCreate = useCallback((eventData: Partial<CalendarEvent>) => {
    console.log("Create event:", eventData);
    // TODO: Open event creation modal with pre-filled data
    // For now, just add a sample event
    const newEvent: CalendarEvent = {
      id: Date.now().toString(),
      calendarId: "work",
      title: "New Event",
      start: eventData.start || new Date(),
      end: eventData.end || new Date(),
      category: eventData.isAllDay ? "allday" : "time",
    };
    setEvents((prev) => [...prev, newEvent]);
  }, []);

  /**
   * Handle updating an event (drag/drop, resize)
   */
  const handleEventUpdate = useCallback(
    (event: CalendarEvent, changes: Partial<CalendarEvent>) => {
      console.log("Update event:", event, changes);
      setEvents((prev) =>
        prev.map((e) => (e.id === event.id ? { ...e, ...changes } : e)),
      );
    },
    [],
  );

  /**
   * Handle deleting an event
   */
  const handleEventDelete = useCallback((event: CalendarEvent) => {
    console.log("Delete event:", event);
    setEvents((prev) => prev.filter((e) => e.id !== event.id));
  }, []);

  // ============================================
  // FORMAT HELPERS
  // ============================================

  /**
   * Format the current date display based on view
   */
  const formatDateDisplay = () => {
    const options: Intl.DateTimeFormatOptions = {
      month: "long",
      year: "numeric",
    };

    if (currentView === "day") {
      options.day = "numeric";
    }

    return currentDate.toLocaleDateString("en-US", options);
  };

  // ============================================
  // RENDER
  // ============================================

  return (
    <main>
      <Layout>
        <div className='flex flex-1 flex-col gap-4 p-4 pt-0'>
          {/* Main content: Calendar (left) | Tasks (right) */}
          <div className='grid gap-4 lg:grid-cols-[1fr_380px] flex-1'>
            {/* Calendar View - Left */}
            <div className='flex flex-col gap-3'>
              {/* Calendar Header with Navigation */}
              <div className='flex items-center justify-between'>
                <div className='flex items-center gap-2'>
                  {/* Previous/Next Navigation */}
                  <button
                    onClick={handlePrev}
                    className='p-2 rounded-lg hover:bg-muted transition-colors'
                    title='Previous'>
                    <ChevronLeft className='size-4' />
                  </button>

                  {/* Current Date Display */}
                  <h2 className='font-semibold text-lg min-w-[160px] text-center'>
                    {formatDateDisplay()}
                  </h2>

                  <button
                    onClick={handleNext}
                    className='p-2 rounded-lg hover:bg-muted transition-colors'
                    title='Next'>
                    <ChevronRight className='size-4' />
                  </button>

                  {/* Today Button */}
                  <button
                    onClick={handleToday}
                    className='px-3 py-1.5 text-sm rounded-lg bg-muted/50 hover:bg-muted transition-colors ml-2'>
                    Today
                  </button>
                </div>

                {/* View Toggle Buttons */}
                <div className='flex gap-1'>
                  <button
                    onClick={() => handleViewChange("day")}
                    className={cn(
                      "px-3 py-1.5 text-sm rounded-lg transition-colors",
                      currentView === "day"
                        ? "bg-primary text-primary-foreground"
                        : "bg-muted/50 hover:bg-muted",
                    )}>
                    Day
                  </button>
                  <button
                    onClick={() => handleViewChange("week")}
                    className={cn(
                      "px-3 py-1.5 text-sm rounded-lg transition-colors",
                      currentView === "week"
                        ? "bg-primary text-primary-foreground"
                        : "bg-muted/50 hover:bg-muted",
                    )}>
                    Week
                  </button>
                  <button
                    onClick={() => handleViewChange("month")}
                    className={cn(
                      "px-3 py-1.5 text-sm rounded-lg transition-colors",
                      currentView === "month"
                        ? "bg-primary text-primary-foreground"
                        : "bg-muted/50 hover:bg-muted",
                    )}>
                    Month
                  </button>
                </div>
              </div>

              {/* Toast UI Calendar Component */}
              <TuiCalendar
                view={currentView}
                events={events}
                onEventClick={handleEventClick}
                onEventCreate={handleEventCreate}
                onEventUpdate={handleEventUpdate}
                onEventDelete={handleEventDelete}
                height='calc(100vh - 180px)'
                className='flex-1 min-h-[500px]'
              />
            </div>

            {/* Tasks Panel - Right */}
            <div className='flex flex-col gap-3'>
              {/* Tasks Header with Timer Toggle */}
              <div className='flex items-center justify-between'>
                <h2 className='font-semibold'>Tasks</h2>
                <div className='flex items-center gap-2'>
                  <button
                    onClick={() => setShowTimer(!showTimer)}
                    className={cn(
                      "flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm transition-all",
                      showTimer
                        ? "bg-primary text-primary-foreground"
                        : "bg-muted/50 hover:bg-muted",
                    )}>
                    <Timer className='size-4' />
                    Timer
                  </button>
                  <button className='p-1.5 rounded-lg bg-muted/50 hover:bg-muted transition-colors'>
                    <Plus className='size-4' />
                  </button>
                </div>
              </div>

              {/* Timer Widget - Toggleable */}
              <div
                className={cn(
                  "overflow-hidden transition-all duration-300 ease-in-out",
                  showTimer ? "max-h-[200px] opacity-100" : "max-h-0 opacity-0",
                )}>
                <div className='bg-card border rounded-xl p-4 flex items-center gap-4'>
                  <div className='relative'>
                    <div className='w-20 h-20 rounded-full border-4 border-primary/30 flex items-center justify-center'>
                      <svg className='absolute inset-0 w-full h-full -rotate-90'>
                        <circle
                          cx='50%'
                          cy='50%'
                          r='calc(50% - 4px)'
                          fill='none'
                          stroke='currentColor'
                          strokeWidth='4'
                          strokeDasharray='65 100'
                          className='text-primary'
                          strokeLinecap='round'
                        />
                      </svg>
                      <span className='text-lg font-mono font-bold'>16:15</span>
                    </div>
                  </div>
                  <div className='flex-1'>
                    <p className='font-medium'>Focus Session</p>
                    <p className='text-sm text-muted-foreground'>
                      Working on project...
                    </p>
                    <div className='flex gap-2 mt-2'>
                      <button className='px-3 py-1 rounded-lg bg-primary text-primary-foreground text-sm'>
                        Pause
                      </button>
                      <button className='px-3 py-1 rounded-lg bg-muted text-sm'>
                        Stop
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              {/* Tasks List */}
              <div className='flex-1 overflow-auto space-y-2 scrollbar-shadcn-thin'>
                {[
                  {
                    title: "Review PR #142",
                    time: "10:00 AM",
                    tags: ["Work", "High"],
                    done: false,
                  },
                  {
                    title: "Update documentation",
                    time: "11:30 AM",
                    tags: ["Work"],
                    done: false,
                  },
                  {
                    title: "Team standup meeting",
                    time: "2:00 PM",
                    tags: ["Meeting"],
                    done: true,
                  },
                  {
                    title: "Code review session",
                    time: "3:30 PM",
                    tags: ["Work"],
                    done: false,
                  },
                  {
                    title: "Plan next sprint",
                    time: "4:00 PM",
                    tags: ["Planning"],
                    done: false,
                  },
                ].map((task, i) => (
                  <div
                    key={i}
                    className={cn(
                      "bg-card border rounded-lg p-3 space-y-2 transition-opacity",
                      task.done && "opacity-60",
                    )}>
                    <div className='flex items-start gap-3'>
                      <div
                        className={cn(
                          "mt-0.5 size-4 rounded border-2 flex items-center justify-center cursor-pointer transition-colors",
                          task.done
                            ? "bg-primary border-primary"
                            : "border-muted-foreground/50 hover:border-primary",
                        )}>
                        {task.done && (
                          <span className='text-primary-foreground text-xs'>
                            ✓
                          </span>
                        )}
                      </div>
                      <div className='flex-1'>
                        <p
                          className={cn(
                            "font-medium",
                            task.done && "line-through",
                          )}>
                          {task.title}
                        </p>
                        <div className='flex items-center gap-2 mt-1 text-xs text-muted-foreground'>
                          <Clock className='size-3' />
                          <span>{task.time}</span>
                        </div>
                      </div>
                    </div>
                    <div className='flex gap-2 pl-7'>
                      {task.tags.map((tag) => (
                        <span
                          key={tag}
                          className={cn(
                            "px-2 py-0.5 rounded-full text-xs",
                            tag === "High"
                              ? "bg-destructive/10 text-destructive"
                              : tag === "Meeting"
                                ? "bg-chart-2/10 text-chart-2"
                                : "bg-primary/10 text-primary",
                          )}>
                          {tag}
                        </span>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </Layout>
    </main>
  );
}
