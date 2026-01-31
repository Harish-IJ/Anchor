import Layout from "@/components/layout";

export default function PomodoroPage() {
  return (
    <main>
      <Layout>
        <div className='flex flex-1 flex-col items-center justify-center min-h-[calc(100vh-4rem)] p-4'>
          {/* Zen Mode Container */}
          <div className='flex flex-col items-center gap-8 max-w-md w-full'>
            {/* Session Type Indicator */}
            <div className='flex gap-2'>
              <div className='bg-primary/20 text-primary px-4 py-1.5 rounded-full text-sm font-medium'>
                Focus
              </div>
              <div className='bg-muted/50 text-muted-foreground px-4 py-1.5 rounded-full text-sm'>
                Short Break
              </div>
              <div className='bg-muted/50 text-muted-foreground px-4 py-1.5 rounded-full text-sm'>
                Long Break
              </div>
            </div>

            {/* Main Timer Circle */}
            <div className='relative'>
              {/* Outer ring - progress indicator */}
              <div className='w-64 h-64 md:w-80 md:h-80 rounded-full border-8 border-muted/30 relative'>
                {/* Progress arc placeholder */}
                <svg className='absolute inset-0 w-full h-full -rotate-90'>
                  <circle
                    cx='50%'
                    cy='50%'
                    r='calc(50% - 4px)'
                    fill='none'
                    stroke='currentColor'
                    strokeWidth='8'
                    strokeDasharray='75 100'
                    className='text-primary'
                    strokeLinecap='round'
                  />
                </svg>
                {/* Timer display */}
                <div className='absolute inset-0 flex flex-col items-center justify-center'>
                  <span className='text-6xl md:text-7xl font-mono font-bold tracking-tight'>
                    18:45
                  </span>
                  <span className='text-muted-foreground text-sm mt-2'>
                    Session 3 of 4
                  </span>
                </div>
              </div>
            </div>

            {/* Current Task */}
            <div className='text-center space-y-1'>
              <p className='text-lg font-medium'>Working on...</p>
              <div className='bg-muted/50 h-6 w-48 rounded-lg animate-pulse mx-auto' />
            </div>

            {/* Controls */}
            <div className='flex items-center gap-4'>
              <button className='p-3 rounded-full bg-muted/50 hover:bg-muted transition-colors'>
                <div className='w-6 h-6 bg-muted-foreground/50 rounded animate-pulse' />
              </button>
              <button className='w-16 h-16 rounded-full bg-primary flex items-center justify-center shadow-lg shadow-primary/25 hover:shadow-primary/40 transition-shadow'>
                <div className='w-0 h-0 border-l-[12px] border-l-primary-foreground border-y-[8px] border-y-transparent ml-1' />
              </button>
              <button className='p-3 rounded-full bg-muted/50 hover:bg-muted transition-colors'>
                <div className='w-6 h-6 bg-muted-foreground/50 rounded animate-pulse' />
              </button>
            </div>

            {/* Session Stats */}
            <div className='grid grid-cols-3 gap-6 w-full max-w-sm pt-4 border-t border-border/50'>
              <div className='text-center'>
                <div className='text-2xl font-bold'>3</div>
                <div className='text-xs text-muted-foreground'>Sessions</div>
              </div>
              <div className='text-center'>
                <div className='text-2xl font-bold'>1:15</div>
                <div className='text-xs text-muted-foreground'>Focus Time</div>
              </div>
              <div className='text-center'>
                <div className='text-2xl font-bold'>5</div>
                <div className='text-xs text-muted-foreground'>Day Streak</div>
              </div>
            </div>

            {/* Ambient Sound Toggle (placeholder) */}
            <div className='flex items-center gap-3 text-sm text-muted-foreground'>
              <div className='w-8 h-8 rounded-full bg-muted/50 animate-pulse' />
              <span>Ambient sounds</span>
              <div className='w-10 h-5 rounded-full bg-muted/50 animate-pulse' />
            </div>
          </div>
        </div>
      </Layout>
    </main>
  );
}
