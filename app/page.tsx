import Layout from "@/components/layout";

export default function DashboardPage() {
  return (
    <main>
      <Layout>
        <div className='flex flex-1 flex-col gap-6 p-4 pt-0'>
          {/* Header */}
          <div className='flex items-center justify-between'>
            <div>
              <h1 className='text-2xl font-bold'>Dashboard</h1>
              <p className='text-muted-foreground'>
                Your productivity at a glance
              </p>
            </div>
            <div className='flex gap-2'>
              <div className='bg-muted/50 h-9 w-28 rounded-lg animate-pulse' />
            </div>
          </div>

          {/* Stats Cards Row */}
          <div className='grid gap-4 sm:grid-cols-2 lg:grid-cols-4'>
            {/* Focus Time Today */}
            <div className='bg-card border rounded-xl p-5'>
              <div className='flex items-center justify-between'>
                <p className='text-sm font-medium text-muted-foreground'>
                  Focus Time Today
                </p>
                <div className='p-2 rounded-lg bg-primary/10'>
                  <div className='w-4 h-4 bg-primary/50 rounded animate-pulse' />
                </div>
              </div>
              <div className='mt-3'>
                <span className='text-3xl font-bold'>2h 45m</span>
                <p className='text-xs text-muted-foreground mt-1'>
                  <span className='text-emerald-500'>+23%</span> from yesterday
                </p>
              </div>
            </div>

            {/* Tasks Completed */}
            <div className='bg-card border rounded-xl p-5'>
              <div className='flex items-center justify-between'>
                <p className='text-sm font-medium text-muted-foreground'>
                  Tasks Completed
                </p>
                <div className='p-2 rounded-lg bg-chart-2/10'>
                  <div className='w-4 h-4 bg-chart-2/50 rounded animate-pulse' />
                </div>
              </div>
              <div className='mt-3'>
                <span className='text-3xl font-bold'>8</span>
                <span className='text-lg text-muted-foreground ml-1'>/ 12</span>
                <p className='text-xs text-muted-foreground mt-1'>
                  4 tasks remaining
                </p>
              </div>
            </div>

            {/* Current Streak */}
            <div className='bg-card border rounded-xl p-5'>
              <div className='flex items-center justify-between'>
                <p className='text-sm font-medium text-muted-foreground'>
                  Current Streak
                </p>
                <div className='p-2 rounded-lg bg-chart-4/10'>
                  <div className='w-4 h-4 bg-chart-4/50 rounded animate-pulse' />
                </div>
              </div>
              <div className='mt-3'>
                <span className='text-3xl font-bold'>7</span>
                <span className='text-lg text-muted-foreground ml-1'>days</span>
                <p className='text-xs text-muted-foreground mt-1'>
                  Personal best: 14 days
                </p>
              </div>
            </div>

            {/* Sessions Today */}
            <div className='bg-card border rounded-xl p-5'>
              <div className='flex items-center justify-between'>
                <p className='text-sm font-medium text-muted-foreground'>
                  Sessions Today
                </p>
                <div className='p-2 rounded-lg bg-chart-5/10'>
                  <div className='w-4 h-4 bg-chart-5/50 rounded animate-pulse' />
                </div>
              </div>
              <div className='mt-3'>
                <span className='text-3xl font-bold'>5</span>
                <p className='text-xs text-muted-foreground mt-1'>
                  Target: 8 sessions
                </p>
              </div>
            </div>
          </div>

          {/* Charts Row */}
          <div className='grid gap-4 lg:grid-cols-7'>
            {/* Weekly Focus Chart */}
            <div className='bg-card border rounded-xl p-5 lg:col-span-4'>
              <div className='flex items-center justify-between mb-4'>
                <div>
                  <h3 className='font-semibold'>Weekly Focus Time</h3>
                  <p className='text-sm text-muted-foreground'>
                    Hours spent in focus sessions
                  </p>
                </div>
                <div className='flex gap-1'>
                  <div className='bg-muted/50 h-8 w-16 rounded animate-pulse' />
                  <div className='bg-muted/50 h-8 w-16 rounded animate-pulse' />
                </div>
              </div>
              {/* Bar chart placeholder */}
              <div className='h-64 flex items-end justify-around gap-2 pt-4'>
                {[65, 45, 80, 55, 90, 40, 75].map((height, i) => (
                  <div
                    key={i}
                    className='flex-1 flex flex-col items-center gap-2'>
                    <div
                      className='w-full bg-primary/80 rounded-t-md transition-all hover:bg-primary'
                      style={{ height: `${height}%` }}
                    />
                    <span className='text-xs text-muted-foreground'>
                      {["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][i]}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* Task Distribution */}
            <div className='bg-card border rounded-xl p-5 lg:col-span-3'>
              <div className='mb-4'>
                <h3 className='font-semibold'>Task Categories</h3>
                <p className='text-sm text-muted-foreground'>
                  Distribution by category
                </p>
              </div>
              {/* Donut chart placeholder */}
              <div className='flex items-center justify-center py-4'>
                <div className='relative w-40 h-40'>
                  <svg
                    className='w-full h-full -rotate-90'
                    viewBox='0 0 100 100'>
                    <circle
                      cx='50'
                      cy='50'
                      r='40'
                      fill='none'
                      stroke='currentColor'
                      strokeWidth='12'
                      className='text-primary'
                      strokeDasharray='75 100'
                    />
                    <circle
                      cx='50'
                      cy='50'
                      r='40'
                      fill='none'
                      stroke='currentColor'
                      strokeWidth='12'
                      className='text-chart-2'
                      strokeDasharray='40 100'
                      strokeDashoffset='-75'
                    />
                    <circle
                      cx='50'
                      cy='50'
                      r='40'
                      fill='none'
                      stroke='currentColor'
                      strokeWidth='12'
                      className='text-chart-4'
                      strokeDasharray='25 100'
                      strokeDashoffset='-115'
                    />
                  </svg>
                  <div className='absolute inset-0 flex items-center justify-center'>
                    <span className='text-2xl font-bold'>12</span>
                  </div>
                </div>
              </div>
              <div className='space-y-2 mt-4'>
                <div className='flex items-center justify-between text-sm'>
                  <div className='flex items-center gap-2'>
                    <div className='w-3 h-3 rounded-full bg-primary' />
                    <span>Work</span>
                  </div>
                  <span className='font-medium'>6 tasks</span>
                </div>
                <div className='flex items-center justify-between text-sm'>
                  <div className='flex items-center gap-2'>
                    <div className='w-3 h-3 rounded-full bg-chart-2' />
                    <span>Personal</span>
                  </div>
                  <span className='font-medium'>4 tasks</span>
                </div>
                <div className='flex items-center justify-between text-sm'>
                  <div className='flex items-center gap-2'>
                    <div className='w-3 h-3 rounded-full bg-chart-4' />
                    <span>Learning</span>
                  </div>
                  <span className='font-medium'>2 tasks</span>
                </div>
              </div>
            </div>
          </div>

          {/* Recent Activity */}
          <div className='bg-card border rounded-xl p-5'>
            <div className='flex items-center justify-between mb-4'>
              <div>
                <h3 className='font-semibold'>Recent Activity</h3>
                <p className='text-sm text-muted-foreground'>
                  Your latest productivity sessions
                </p>
              </div>
              <div className='bg-muted/50 h-8 w-20 rounded animate-pulse' />
            </div>
            <div className='space-y-3'>
              {[
                {
                  time: "2 min ago",
                  action: "Completed focus session",
                  duration: "25 min",
                  type: "focus",
                },
                {
                  time: "32 min ago",
                  action: "Finished task: Review PR #142",
                  duration: "",
                  type: "task",
                },
                {
                  time: "1h ago",
                  action: "Completed focus session",
                  duration: "25 min",
                  type: "focus",
                },
                {
                  time: "2h ago",
                  action: "Added task: Update documentation",
                  duration: "",
                  type: "task",
                },
                {
                  time: "3h ago",
                  action: "Completed focus session",
                  duration: "25 min",
                  type: "focus",
                },
              ].map((item, i) => (
                <div
                  key={i}
                  className='flex items-center gap-4 py-2 border-b border-border/50 last:border-0'>
                  <div
                    className={`w-2 h-2 rounded-full ${item.type === "focus" ? "bg-primary" : "bg-chart-2"}`}
                  />
                  <div className='flex-1'>
                    <p className='text-sm font-medium'>{item.action}</p>
                    <p className='text-xs text-muted-foreground'>{item.time}</p>
                  </div>
                  {item.duration && (
                    <span className='text-xs bg-muted px-2 py-1 rounded'>
                      {item.duration}
                    </span>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      </Layout>
    </main>
  );
}
