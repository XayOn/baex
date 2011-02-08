/**
 * Copyright (c) 2005 - 2010, Eric Van Dewoestine
 * All rights reserved.
 *
 * Redistribution and use of this software in source and binary forms, with
 * or without modification, are permitted provided that the following
 * conditions are met:
 *
 * * Redistributions of source code must retain the above
 *   copyright notice, this list of conditions and the
 *   following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above
 *   copyright notice, this list of conditions and the
 *   following disclaimer in the documentation and/or other
 *   materials provided with the distribution.
 *
 * * Neither the name of Eric Van Dewoestine nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission of
 *   Eric Van Dewoestine.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package archive;

import java.text.SimpleDateFormat;

import java.util.Date;

/**
 * Utilities methods for working with archives.
 *
 * @author Eric Van Dewoestine
 */
public class ArchiveUtils
{
  private static final SimpleDateFormat DATE_FORMAT =
    new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

  public static String formatTime(long time)
    throws Exception
  {
    return DATE_FORMAT.format(new Date(time));
  }

  public static String formatTime(Date time)
    throws Exception
  {
    return DATE_FORMAT.format(time);
  }

  public static String rightPad(String value, int length)
  {
    StringBuffer buffer = new StringBuffer(value);
    while(buffer.length() < length){
      buffer.append(' ');
    }
    return buffer.toString();
  }
}
