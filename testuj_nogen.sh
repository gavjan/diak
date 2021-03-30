#!/usr/bin/bash

# Wiem, prymitywne. Nie bijcie :(
if [[ $# -ne 1 ]]; 
then
  echo "I like trains. And program to test as the argument.";
else
  echo "Testing: $1";

  echo -n "Tresc3: ";
  if echo "ŁOŚ" | $1 1075041 623420 1 > t.out;
  then
    if cmp -l t.out tresc3.out;
    then
      echo "OK";
    else
      echo "FAILED";
    fi
  else
    echo "FAILED";
  fi

  echo -n "Tresc2: ";
  if echo "Zażółć gęślą jaźń…" | $1 133 > t.out;
  then
    if cmp -l t.out tresc2.out;
    then
      echo "OK";
    else
      echo "FAILED";
    fi
  else
    echo "FAILED";
  fi

  echo -n "Tresc4: ";
  if echo -e "abc\n\x80" | $1 7 > t.out;
  then
    echo "FAILED"; 
  else
    if cmp -l t.out tresc4.out;
    then
      echo "OK";
    else
      echo "FAILED";
    fi
  fi

  echo -n "Incorrect UTF-8, 2Bv1: ";
  if echo -ne "\xC0\xAA" | $1 0 1 > /dev/null;
  then
    echo "FAILED";
  else
    echo "OK";
  fi

  echo -n "Incorrect UTF-8, 2Bv2: ";
  if echo -ne "\xC1\xBF" | $1 0 1 > /dev/null;
  then
    echo "FAILED";
  else
    echo "OK";
  fi

  echo -n "Incorrect UTF-8, 3Bv1: ";
  if echo -ne "\xE0\x00\xAA" | $1 0 1 > /dev/null;
  then
    echo "FAILED";
  else
    echo "OK";
  fi

  echo -n "Incorrect UTF-8, 3Bv2: ";
  if echo -ne "\xE0\x9F\x95" | $1 0 1 > /dev/null;
  then
    echo "FAILED";
  else
    echo "OK";
  fi

  echo -n "Incorrect UTF-8, 4Bv1: ";
  if echo -ne "\xF0\x00\x00\x41" | $1 0 1 > /dev/null;
  then
    echo "FAILED";
  else
    echo "OK";
  fi

  echo -n "Incorrect UTF-8, 4Bv2: ";
  if echo -ne "\xF0\x80\x00\x41" | $1 0 1 > /dev/null;
  then
    echo "FAILED";
  else
    echo "OK";
  fi

  echo -n "Incorrect UTF-8, 4Bv3: ";
  if echo -ne "\xF0\x80\x80\x41" | $1 0 1 > /dev/null;
  then
    echo "FAILED";
  else
    echo "OK";
  fi

  echo -n "Incorrect UTF-8, 4Bv4: ";
  if echo -ne "\xF0\x80\x82\x80" | $1 0 1 > /dev/null;
  then
    echo "FAILED";
  else
    echo "OK";
  fi
  
  echo -n "Incorrect UTF-8, 4Bv5: ";
  if echo -ne "\xF0\x88\x82\x80" | $1 0 1 > /dev/null;
  then
    echo "FAILED";
  else
    echo "OK";
  fi

  echo -n "Incorrect UTF-8, misc1: ";
  if echo -ne "\xF8\x90\x82\x80" | $1 0 1 > /dev/null;
  then
    echo "FAILED";
  else
    echo "OK";
  fi

  echo -n "Incorrect UTF-8, misc2: ";
  if echo -ne "\xF7\xBF\xBF\xBF" | $1 0 1 > /dev/null;
  then
    echo "FAILED";
  else
    echo "OK";
  fi

  echo -n "Correct UTF-8: ";
  if echo -ne "\xF4\x8F\xBF\xBF" | $1 0 1 > /dev/null;
  then
    echo "OK";
  else
    echo "FAILED";
  fi

  echo -n "Incorrect UTF-8, misc3: ";
  if echo -ne "\xF4\x90\x80\x80" | $1 0 1 > /dev/null;
  then
    echo "FAILED";
  else
    echo "OK";
  fi

  # Proste testy sprawdzające, czy potrafimy czytać utf-8 i poprawnie go wypisać
  echo -n "Unicode read test: ";
  if $1 $(cat ./unicodeTest.args) < utf8_everycode.in | cmp -l ./utf8_everycode.in;
  then
    echo "OK";
  else
    echo "FAIL";
  fi
  echo -n "Unicode read stress test, 1 packet: ";
  if $1 $(cat ./unicodeTest.args) < smoll.in > t.out;
  then
    if cmp -l smoll.in t.out;
    then
      echo "OK";
    else
      echo "FAIL";
    fi
  else
    echo "FAIL";
  fi
  echo -n "Unicode read stress test, 10 packets: ";
  if $1 $(cat ./unicodeTest.args) < big.in > t.out;
  then
    if cmp -l big.in t.out;
    then
      echo "OK";
    else
      echo "FAIL";
    fi
  else
    echo "FAIL";
  fi

  # Testy sprawdzające, czy potrafimy liczyć wielomian.
  echo -n "Polynomial test smoll: ";
  if $1 $(cat ./polynomialTest.args) < smoll.in > t.out;
  then
  if cmp -l t.out smoll_polynomial.out;
    then
      echo "OK";
    else
      echo "FAIL";
    fi
  fi

  echo -n "Polynomial test not smoll: ";
  if $1 $(cat ./polynomialTest.args) < big.in > t.out;
  then
    if cmp -l t.out big_polynomial.out;
    then 
      echo "OK";
    else
      echo "FAIL";
    fi
  fi

  echo -n "Not smoll polynomial test that is not smoll: ";
  if $1 $(cat ./notSmollPolynomialTest.args) < big.in > t.out;
  then
    if cmp -l t.out verybig_polynomial.out;
    then
      echo "OK";
    else
      echo "FAIL";
    fi
  fi
fi
