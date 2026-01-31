"use client";

import * as React from "react";
import {
  LayoutDashboard,
  CalendarDays,
  Timer,
  Settings,
  Anchor,
  ChevronsLeft,
  ChevronsRight,
} from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";

import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarGroup,
  SidebarGroupLabel,
  useSidebar,
} from "@/components/ui/sidebar";
import { cn } from "@/lib/utils";

const navItems = [
  {
    title: "Dashboard",
    url: "/",
    icon: LayoutDashboard,
  },
  {
    title: "Schedule",
    url: "/schedule",
    icon: CalendarDays,
  },
  {
    title: "Pomodoro",
    url: "/pomodoro",
    icon: Timer,
  },
];

const otherItems = [
  {
    title: "Settings",
    url: "/settings",
    icon: Settings,
  },
];

function CollapseButton() {
  const { toggleSidebar, state } = useSidebar();

  return (
    <button
      onClick={toggleSidebar}
      className='flex items-center justify-center size-8 rounded-lg hover:bg-white/10 transition-colors'>
      {state === "expanded" ? (
        <ChevronsLeft className='size-4' />
      ) : (
        <ChevronsRight className='size-4' />
      )}
    </button>
  );
}

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
  const pathname = usePathname();

  return (
    <Sidebar
      variant='floating'
      collapsible='icon'
      className='glassmorphism-sidebar'
      {...props}>
      <SidebarHeader className='pb-0'>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton size='lg' asChild className='hover:bg-white/10'>
              <div className='flex items-center justify-between w-full'>
                <Link href='/' className='flex items-center gap-2'>
                  <div className='bg-primary text-primary-foreground flex aspect-square size-8 items-center justify-center rounded-xl'>
                    <Anchor className='size-4' />
                  </div>
                  <div className='grid flex-1 text-left text-sm leading-tight group-data-[collapsible=icon]:hidden'>
                    <span className='truncate font-semibold'>Anchor</span>
                    <span className='truncate text-xs opacity-60'>
                      Productivity
                    </span>
                  </div>
                </Link>
                <div className='group-data-[collapsible=icon]:hidden'>
                  <CollapseButton />
                </div>
              </div>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>

      <SidebarContent className='px-2'>
        {/* Main Navigation */}
        <SidebarGroup>
          <SidebarGroupLabel className='text-xs uppercase tracking-wider opacity-50'>
            Main
          </SidebarGroupLabel>
          <SidebarMenu className='gap-1'>
            {navItems.map((item) => {
              const isActive = pathname === item.url;
              return (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton
                    asChild
                    isActive={isActive}
                    tooltip={item.title}
                    className={cn(
                      "relative transition-all duration-200",
                      isActive && "bg-white/20 text-white",
                    )}>
                    <Link href={item.url} onClick={(e) => e.stopPropagation()}>
                      <item.icon className='size-4' />
                      <span className='group-data-[collapsible=icon]:hidden'>
                        {item.title}
                      </span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              );
            })}
          </SidebarMenu>
        </SidebarGroup>

        {/* Other Navigation */}
        <SidebarGroup className='mt-auto'>
          <SidebarGroupLabel className='text-xs uppercase tracking-wider opacity-50'>
            Other
          </SidebarGroupLabel>
          <SidebarMenu className='gap-1'>
            {otherItems.map((item) => {
              const isActive = pathname === item.url;
              return (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton
                    asChild
                    isActive={isActive}
                    tooltip={item.title}
                    className={cn(
                      "relative transition-all duration-200",
                      isActive && "bg-white/20 text-white",
                    )}>
                    <Link href={item.url} onClick={(e) => e.stopPropagation()}>
                      <item.icon className='size-4' />
                      <span className='group-data-[collapsible=icon]:hidden'>
                        {item.title}
                      </span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              );
            })}
          </SidebarMenu>
        </SidebarGroup>
      </SidebarContent>

      <SidebarFooter className='group-data-[collapsible=icon]:hidden'>
        <div className='flex items-center justify-center'>
          <CollapseButton />
        </div>
      </SidebarFooter>
    </Sidebar>
  );
}
