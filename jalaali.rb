def toJalaali(gy, gm, gd)
  d2j(g2d(gy, gm, gd))
end


# Converts a Jalaali date to Gregorian.
def toGregorian(jy, jm, jd)
  d2g(j2d(jy, jm, jd))
end

# Checks whether a Jalaali date is valid or not.
def isValidJalaaliDate(jy, jm, jd)
  jy >= -61 && jy <= 3177 &&
  jm >= 1 && jm <= 12 &&
  jd >= 1 && jd <= jalaaliMonthLength(jy, jm)
end

  # Is this a leap year or not?
def isLeapJalaaliYear(jy)
  jalCal(jy)[:leap] == 0
end

def jalaaliMonthLength(jy, jm)
  if jm <= 6
    31
  elsif jm <= 11 or isLeapJalaaliYear(jy)
    30
  else
    29
  end
end

  # This function determines if the Jalaali (Persian) year is
  # leap (366-day long) or is the common year (365 days), and
  # finds the day in March (Gregorian calendar) of the first
  # day of the Jalaali year (jy).

  # @param jy Jalaali calendar year (-61 to 3177)
  # @return
  #   leap: number of years since the last leap year (0 to 4)
  #   gy: Gregorian year of the beginning of Jalaali year
  #   march: the March day of Farvardin the 1st (1st day of jy)
  # @see: http://www.astro.uni.torun.pl/~kb/Papers/EMP/PersianC-EMP.htm
  # @see: http://www.fourmilab.ch/documents/calendar/
def jalCal(jy)
 # Jalaali years starting the 33-year rule.
  breaks =  [ -61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210, 1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178]
  bl = breaks.length
  gy = jy + 621
  leapJ = -14
  jp = breaks[0]
  jm = nil
  jump = nil
  leap = nil
  leapG = nil

  n = nil
  i = nil

  if (jy < jp || jy >= breaks[bl - 1])
    raise 'Invalid Jalaali year ' + jy
  end
  # Find the limiting years for the Jalaali year jy.

  for i  in 1..bl do
    jm = breaks[i]
    jump = jm - jp
    break if (jy < jm)
    leapJ = leapJ + div(jump, 33) * 8 + div(mod(jump, 33), 4)
    jp = jm
  end
  n = jy - jp

  # Find the number of leap years from AD 621 to the beginning
  # of the current Jalaali year in the Persian calendar.
  leapJ = leapJ + div(n, 33) * 8 + div(mod(n, 33) + 3, 4)
  if (mod(jump, 33) == 4 && jump - n == 4)
    leapJ += 1
  end
  # And the same in the Gregorian calendar (until the year gy).
  leapG = div(gy, 4) - div((div(gy, 100) + 1) * 3, 4) - 150

  # Determine the Gregorian date of Farvardin the 1st.
  march = 20 + leapJ - leapG

  # Find how many years have passed since the last leap year.
  if (jump - n < 6)
    n = n - jump + div(jump + 4, 33) * 33
  end
  leap = mod(mod(n + 1, 33) - 1, 4)
  if (leap == -1)
    leap = 4
  end
  { leap: leap, gy: gy, march: march}
end


  # Converts a date of the Jalaali calendar to the Julian Day number.

  # @param jy Jalaali year (1 to 3100)
  # @param jm Jalaali month (1 to 12)
  # @param jd Jalaali day (1 to 29/31)
  # @return Julian Day number
def j2d(jy, jm, jd)
  r = jalCal(jy)
  g2d(r.gy, 3, r[:march]) + (jm - 1) * 31 - div(jm, 7) * (jm - 7) + jd - 1
end

  # Converts the Julian Day number to a date in the Jalaali calendar.

  # @param jdn Julian Day number
  # @return
  #   jy: Jalaali year (1 to 3100)
  #   jm: Jalaali month (1 to 12)
  #   jd: Jalaali day (1 to 29/31)
def d2j(jdn)
  gy = d2g(jdn)[:gy] # Calculate Gregorian year (gy).
  jy = gy - 621
  r = jalCal(jy)
  jdn1f = g2d(gy, 3, r[:march])
  # Find number of days that passed since 1 Farvardin.
  k = jdn - jdn1f
  if (k >= 0)
    if (k <= 185)
      # The first 6 months.
      jm = 1 + div(k, 31)
      jd = mod(k, 31) + 1
      return  { jy: jy, jm: jm, jd: jd}
    else
      # The remaining months.
      k -= 186
    end
  else
    # Previous Jalaali year.
    jy -= 1
    k += 179
    k += 1 if (r[:leap] == 1)
  end
  jm = 7 + div(k, 30)
  jd = mod(k, 30) + 1
  { jy: jy, jm: jm, jd: jd}
end


  # Calculates the Julian Day number from Gregorian or Julian
  # calendar dates. This integer number corresponds to the noon of
  # the date (i.e. 12 hours of Universal Time).
  # The procedure was tested to be good since 1 March, -100100 (of both
  # calendars) up to a few million years into the future.

  # @param gy Calendar year (years BC numbered 0, -1, -2, ...)
  # @param gm Calendar month (1 to 12)
  # @param gd Calendar day of the month (1 to 28/29/30/31)
  # @return Julian Day number

def g2d(gy, gm, gd)
  inner = (gy + div(gm - 8, 6) + 100100) * 1461
  d = div(inner, 4)
  d = d + div(153 * mod(gm + 9, 12) + 2, 5)
  d = d + gd - 34840408
  d = d - div(div(gy + 100100 + div(gm - 8, 6), 100) * 3, 4) + 752
end


  # Calculates Gregorian and Julian calendar dates from the Julian Day number
  # (jdn) for the period since jdn=-34839655 (i.e. the year -100100 of both
  # calendars) to some millions years ahead of the present.

  # @param jdn Julian Day number
  # @return
  #   gy: Calendar year (years BC numbered 0, -1, -2, ...)
  #   gm: Calendar month (1 to 12)
  #   gd: Calendar day of the month M (1 to 28/29/30/31)

def d2g(jdn)
  j = 4 * jdn + 139361631
  j = j + div(div(4 * jdn + 183187720, 146097) * 3, 4) * 4 - 3908
  i = div(mod(j, 1461), 4) * 5 + 308
  gd = div(mod(i, 153), 5) + 1
  gm = mod(div(i, 153), 12) + 1
  gy = div(j, 1461) - 100100 + div(8 - gm, 6)
  { gy: gy, gm: gm, gd: gd}
end


  # Utility helper functions.

def div(a, b)
  x = (a / b)
  m = a % b
  x = x + 1 if x<0 and m != 0
  x
end

def mod(a, b)
  x =  a % b
  x = x - b if a < 0
  x
end
