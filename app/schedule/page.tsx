import Layout from "@/components/layout";

export default function SchedulePage() {
  return (
    <main>
      <Layout>
        <div className='flex flex-1 flex-col gap-4 p-4 pt-0'>
          {/* Header with date and quick actions */}
          <div className='flex items-center justify-between'>
            <div>
              <h1 className='text-2xl font-bold'>Schedule</h1>
              <p className='text-muted-foreground'>
                Manage your tasks and events
              </p>
            </div>
            <div className='flex gap-2'>
              <div className='bg-muted/50 h-9 w-24 rounded-lg animate-pulse' />
              <div className='bg-primary/20 h-9 w-28 rounded-lg animate-pulse' />
            </div>
          </div>

          {/* Main content grid */}
          <div className='grid gap-4 lg:grid-cols-[300px_1fr] xl:grid-cols-[320px_1fr_280px]'>
            {/* Task List Panel */}
            <div className='flex flex-col gap-3'>
              <div className='flex items-center justify-between'>
                <h2 className='font-semibold'>Tasks</h2>
                <div className='bg-muted/50 h-6 w-6 rounded animate-pulse' />
              </div>
              <div className='space-y-2'>
                {[1, 2, 3, 4, 5].map((i) => (
                  <div
                    key={i}
                    className='bg-card border rounded-lg p-3 space-y-2'>
                    <div className='flex items-start gap-2'>
                      <div className='bg-muted h-4 w-4 rounded mt-0.5 animate-pulse' />
                      <div className='flex-1 space-y-1'>
                        <div className='bg-muted/70 h-4 w-3/4 rounded animate-pulse' />
                        <div className='bg-muted/50 h-3 w-1/2 rounded animate-pulse' />
                      </div>
                    </div>
                    <div className='flex gap-2 pl-6'>
                      <div className='bg-primary/10 h-5 w-14 rounded-full animate-pulse' />
                      <div className='bg-muted/50 h-5 w-16 rounded-full animate-pulse' />
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Calendar View */}
            <div className='flex flex-col gap-3'>
              <div className='flex items-center justify-between'>
                <div className='flex items-center gap-3'>
                  <div className='bg-muted/50 h-8 w-8 rounded animate-pulse' />
                  <div className='bg-muted/70 h-6 w-32 rounded animate-pulse' />
                  <div className='bg-muted/50 h-8 w-8 rounded animate-pulse' />
                </div>
                <div className='flex gap-1'>
                  <div className='bg-muted/50 h-8 w-16 rounded animate-pulse' />
                  <div className='bg-primary/20 h-8 w-16 rounded animate-pulse' />
                  <div className='bg-muted/50 h-8 w-16 rounded animate-pulse' />
                </div>
              </div>
              <div className='bg-card border rounded-xl p-4 flex-1 min-h-[500px]'>
                {/* Time slots grid placeholder */}
                <div className='grid grid-cols-8 gap-px h-full'>
                  {/* Time column */}
                  <div className='space-y-8 pt-8'>
                    {[
                      "8 AM",
                      "9 AM",
                      "10 AM",
                      "11 AM",
                      "12 PM",
                      "1 PM",
                      "2 PM",
                      "3 PM",
                      "4 PM",
                      "5 PM",
                    ].map((time) => (
                      <div
                        key={time}
                        className='text-xs text-muted-foreground text-right pr-2'>
                        {time}
                      </div>
                    ))}
                  </div>
                  {/* Days columns */}
                  {["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map(
                    (day) => (
                      <div key={day} className='border-l border-border/50'>
                        <div className='text-center py-2 text-sm font-medium border-b border-border/50'>
                          {day}
                        </div>
                        <div className='relative h-full'>
                          {/* Random event placeholders */}
                          {day === "Mon" && (
                            <div className='absolute top-16 left-1 right-1 h-16 bg-primary/20 rounded-md animate-pulse' />
                          )}
                          {day === "Wed" && (
                            <div className='absolute top-32 left-1 right-1 h-24 bg-chart-2/30 rounded-md animate-pulse' />
                          )}
                          {day === "Fri" && (
                            <div className='absolute top-8 left-1 right-1 h-12 bg-chart-4/30 rounded-md animate-pulse' />
                          )}
                        </div>
                      </div>
                    ),
                  )}
                </div>
              </div>
            </div>

            {/* Timer Widget (visible on xl screens) */}
            <div className='hidden xl:flex flex-col gap-3'>
              <h2 className='font-semibold'>Quick Timer</h2>
              <div className='bg-card border rounded-xl p-4 flex flex-col items-center gap-4'>
                <div className='relative'>
                  <div className='w-32 h-32 rounded-full border-4 border-primary/20 flex items-center justify-center'>
                    <span className='text-2xl font-mono font-bold text-muted-foreground'>
                      25:00
                    </span>
                  </div>
                </div>
                <div className='text-center'>
                  <div className='bg-muted/50 h-4 w-24 rounded mx-auto animate-pulse' />
                </div>
                <div className='flex gap-2'>
                  <div className='bg-primary h-9 w-20 rounded-lg animate-pulse' />
                  <div className='bg-muted/50 h-9 w-9 rounded-lg animate-pulse' />
                </div>
              </div>
              <div className='bg-card border rounded-xl p-4 mt-2'>
                <h3 className='text-sm font-medium mb-3'>Today&apos;s Focus</h3>
                <div className='space-y-2'>
                  <div className='flex justify-between text-sm'>
                    <span className='text-muted-foreground'>Sessions</span>
                    <span className='font-medium'>4</span>
                  </div>
                  <div className='flex justify-between text-sm'>
                    <span className='text-muted-foreground'>Focus time</span>
                    <span className='font-medium'>1h 40m</span>
                  </div>
                  <div className='h-2 bg-muted rounded-full mt-2'>
                    <div className='h-full w-2/3 bg-primary rounded-full' />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </Layout>
    </main>
  );
}
