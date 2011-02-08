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

import java.io.BufferedInputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.InputStream;

import java.text.Collator;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Enumeration;

import java.util.zip.GZIPInputStream;

import org.apache.tools.bzip2.CBZip2InputStream;

import org.apache.tools.tar.TarEntry;
import org.apache.tools.tar.TarInputStream;

import org.apache.tools.zip.ZipEntry;
import org.apache.tools.zip.ZipFile;

/**
 * Command to list all contents of an archive.
 *
 * @author Eric Van Dewoestine
 */
public class ArchiveListAllCommand
{
  private static final Comparator<String[]> COMPARATOR = new EntryComparator();

  public static final void main(String[] args)
    throws Exception
  {
    new ArchiveListAllCommand().execute(args);
  }

  @SuppressWarnings("unchecked")
  public void execute(String[] args)
    throws Exception
  {
    String file = args[0];
    Object[] results = null;
    if (file.endsWith(".jar") ||
        file.endsWith(".ear") ||
        file.endsWith(".war") ||
        file.endsWith(".egg") ||
        file.endsWith(".zip")){
      results = expandZip(file);
    } else if (file.endsWith(".tar") ||
        file.endsWith(".tar.gz") ||
        file.endsWith(".tar.bz2") ||
        file.endsWith(".tgz") ||
        file.endsWith(".tbz2")){
      results = expandTar(file);
    }

    File tmp = File.createTempFile("vim-archive-", "-contents");
    BufferedWriter out = null;
    try{
      out = new BufferedWriter(new FileWriter(tmp));
      ArrayList<String[]> entries = (ArrayList<String[]>)results[0];
      Collections.sort(entries, COMPARATOR);
      int maxName = (Integer)results[1] + 2;
      int maxSize = (Integer)results[2] + 2;

      for (String[] entry : entries) {
        out.write(
            ArchiveUtils.rightPad(entry[0], maxName) +
            ArchiveUtils.rightPad(entry[1], maxSize) +
            entry[2] + '\n');
      }
    }finally{
      try{
        out.close();
      }catch(Exception ignore){
      }
      //tmp.deleteOnExit();
    }

    System.out.println(tmp.getAbsolutePath());
  }

  @SuppressWarnings("unchecked")
  private Object[] expandZip(String file)
    throws Exception
  {
    ArrayList<String[]> results = new ArrayList<String[]>();
    int maxName = 0;
    int maxSize = 0;

    ZipFile zf = null;
    try{
      zf = new ZipFile(file, "UTF8");
      Enumeration<ZipEntry> e = zf.getEntries();
      while (e.hasMoreElements()) {
        ZipEntry ze = e.nextElement();
        if(!ze.isDirectory()){
          String name = ze.getName();
          String size = String.valueOf(ze.getSize());
          results.add(new String[]{
            name, size, ArchiveUtils.formatTime(ze.getTime())
          });
          maxName = name.length() > maxName ? name.length() : maxName;
          maxSize = size.length() > maxSize ? size.length() : maxSize;
        }
      }
    }finally{
      ZipFile.closeQuietly(zf);
    }
    return new Object[]{results, maxName, maxSize};
  }

  private Object[] expandTar(String file)
    throws Exception
  {
    ArrayList<String[]> results = new ArrayList<String[]>();
    int maxName = 0;
    int maxSize = 0;

    TarInputStream tis = null;
    InputStream in = null;
    try{
      in = new FileInputStream(file);
      if(file.endsWith(".tar.gz") || file.endsWith(".tgz")){
        in = new GZIPInputStream(new BufferedInputStream(in));
      }else if(file.endsWith(".tar.bz2") || file.endsWith(".tbz2")){
        final char[] magic = new char[] {'B', 'Z'};
        for (int i = 0; i < magic.length; i++) {
            if (in.read() != magic[i]) {
                throw new Exception("Invalid bz2 file.");
            }
        }
        in = new CBZip2InputStream(new BufferedInputStream(in));
      }
      tis = new TarInputStream(in);
      TarEntry te = null;
      while ((te = tis.getNextEntry()) != null) {
        if(!te.isDirectory()){
          String name = te.getName();
          String size = String.valueOf(te.getSize());
          results.add(new String[]{
            name, size, ArchiveUtils.formatTime(te.getModTime())
          });
          maxName = name.length() > maxName ? name.length() : maxName;
          maxSize = size.length() > maxSize ? size.length() : maxSize;
        }
      }
    }finally{
      try{
        tis.close();
      }catch(Exception ignore){
      }
      try{
        in.close();
      }catch(Exception ignore){
      }
    }
    return new Object[]{results, maxName, maxSize};
  }

  /*private String toUrl (String archive, String file)
  {
    if (archive.endsWith(".jar") ||
        archive.endsWith(".ear") ||
        archive.endsWith(".war") ||
        archive.endsWith(".egg") ||
        archive.endsWith(".zip"))
    {
      return "jar:" + archive + "!/" + file;
    }

    if(archive.endsWith(".tar")){
      return "tar:" + archive + "!/" + file;
    }

    if(archive.endsWith(".tar.gz") || archive.endsWith(".tgz")){
      return "tgz:" + archive + "!/" + file;
    }

    if(archive.endsWith(".tar.bz2") || archive.endsWith(".tbz2")){
      return "tbz2:" + archive + "!/" + file;
    }
    // shouldn't happen
    return archive + '/' + file;
  }*/

  private static class EntryComparator
    implements Comparator<String[]>
  {
    private static final Collator COLLATOR = Collator.getInstance();

    /**
     * {@inheritDoc}
     * @see Comparator#compare(T,T)
     */
    public int compare(String[] o1, String[] o2)
    {
      return COLLATOR.compare(o1[0], o2[0]);
    }

    /**
     * {@inheritDoc}
     * @see Comparator#equals(Object)
     */
    public boolean equals(Object obj)
    {
      if(obj instanceof EntryComparator){
        return true;
      }
      return false;
    }
  }
}
