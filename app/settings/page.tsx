import Layout from "@/components/layout";

export default function SettingsPage() {
  return (
    <main>
      <Layout>
        <div className='flex flex-1 flex-col gap-6 p-4 pt-0 max-w-4xl'>
          {/* Header */}
          <div>
            <h1 className='text-2xl font-bold'>Settings</h1>
            <p className='text-muted-foreground'>
              Customize your Anchor experience
            </p>
          </div>

          {/* Settings Sections */}
          <div className='space-y-6'>
            {/* General */}
            <section className='bg-card border rounded-xl p-6'>
              <h2 className='font-semibold mb-4'>General</h2>
              <div className='space-y-4'>
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Language</p>
                    <p className='text-sm text-muted-foreground'>
                      Select your preferred language
                    </p>
                  </div>
                  <div className='bg-muted/50 h-9 w-32 rounded-lg animate-pulse' />
                </div>
                <div className='border-t border-border/50' />
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Time Format</p>
                    <p className='text-sm text-muted-foreground'>
                      12-hour or 24-hour format
                    </p>
                  </div>
                  <div className='bg-muted/50 h-9 w-24 rounded-lg animate-pulse' />
                </div>
                <div className='border-t border-border/50' />
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Week Start</p>
                    <p className='text-sm text-muted-foreground'>
                      First day of the week
                    </p>
                  </div>
                  <div className='bg-muted/50 h-9 w-28 rounded-lg animate-pulse' />
                </div>
              </div>
            </section>

            {/* Appearance */}
            <section className='bg-card border rounded-xl p-6'>
              <h2 className='font-semibold mb-4'>Appearance</h2>
              <div className='space-y-4'>
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Theme</p>
                    <p className='text-sm text-muted-foreground'>
                      Choose light, dark, or system theme
                    </p>
                  </div>
                  <div className='flex gap-2'>
                    <div className='w-9 h-9 rounded-lg bg-white border-2 border-primary' />
                    <div className='w-9 h-9 rounded-lg bg-zinc-900 border-2 border-transparent' />
                    <div className='w-9 h-9 rounded-lg bg-gradient-to-br from-white to-zinc-900 border-2 border-transparent' />
                  </div>
                </div>
                <div className='border-t border-border/50' />
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Accent Color</p>
                    <p className='text-sm text-muted-foreground'>
                      Customize the primary color
                    </p>
                  </div>
                  <div className='flex gap-2'>
                    <div className='w-7 h-7 rounded-full bg-violet-500 ring-2 ring-offset-2 ring-offset-background ring-violet-500' />
                    <div className='w-7 h-7 rounded-full bg-blue-500' />
                    <div className='w-7 h-7 rounded-full bg-emerald-500' />
                    <div className='w-7 h-7 rounded-full bg-amber-500' />
                    <div className='w-7 h-7 rounded-full bg-rose-500' />
                  </div>
                </div>
                <div className='border-t border-border/50' />
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Compact Mode</p>
                    <p className='text-sm text-muted-foreground'>
                      Reduce spacing for more content
                    </p>
                  </div>
                  <div className='w-11 h-6 rounded-full bg-muted/50 animate-pulse' />
                </div>
              </div>
            </section>

            {/* Timer Settings */}
            <section className='bg-card border rounded-xl p-6'>
              <h2 className='font-semibold mb-4'>Timer</h2>
              <div className='space-y-4'>
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Focus Duration</p>
                    <p className='text-sm text-muted-foreground'>
                      Length of focus sessions
                    </p>
                  </div>
                  <div className='flex items-center gap-2'>
                    <div className='bg-muted/50 h-9 w-16 rounded-lg animate-pulse' />
                    <span className='text-sm text-muted-foreground'>min</span>
                  </div>
                </div>
                <div className='border-t border-border/50' />
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Short Break</p>
                    <p className='text-sm text-muted-foreground'>
                      Duration between sessions
                    </p>
                  </div>
                  <div className='flex items-center gap-2'>
                    <div className='bg-muted/50 h-9 w-16 rounded-lg animate-pulse' />
                    <span className='text-sm text-muted-foreground'>min</span>
                  </div>
                </div>
                <div className='border-t border-border/50' />
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Long Break</p>
                    <p className='text-sm text-muted-foreground'>
                      Break after 4 sessions
                    </p>
                  </div>
                  <div className='flex items-center gap-2'>
                    <div className='bg-muted/50 h-9 w-16 rounded-lg animate-pulse' />
                    <span className='text-sm text-muted-foreground'>min</span>
                  </div>
                </div>
                <div className='border-t border-border/50' />
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Auto-start Breaks</p>
                    <p className='text-sm text-muted-foreground'>
                      Automatically start break timer
                    </p>
                  </div>
                  <div className='w-11 h-6 rounded-full bg-primary animate-pulse' />
                </div>
              </div>
            </section>

            {/* Notifications */}
            <section className='bg-card border rounded-xl p-6'>
              <h2 className='font-semibold mb-4'>Notifications</h2>
              <div className='space-y-4'>
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Sound Alerts</p>
                    <p className='text-sm text-muted-foreground'>
                      Play sound when timer ends
                    </p>
                  </div>
                  <div className='w-11 h-6 rounded-full bg-primary animate-pulse' />
                </div>
                <div className='border-t border-border/50' />
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Desktop Notifications</p>
                    <p className='text-sm text-muted-foreground'>
                      Show system notifications
                    </p>
                  </div>
                  <div className='w-11 h-6 rounded-full bg-muted/50 animate-pulse' />
                </div>
                <div className='border-t border-border/50' />
                <div className='flex items-center justify-between'>
                  <div>
                    <p className='font-medium'>Task Reminders</p>
                    <p className='text-sm text-muted-foreground'>
                      Remind about upcoming tasks
                    </p>
                  </div>
                  <div className='w-11 h-6 rounded-full bg-primary animate-pulse' />
                </div>
              </div>
            </section>
          </div>
        </div>
      </Layout>
    </main>
  );
}
