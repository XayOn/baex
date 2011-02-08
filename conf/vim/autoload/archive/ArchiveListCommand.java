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

import java.text.Collator;

import java.util.Arrays;
import java.util.Comparator;

import org.apache.commons.vfs.FileContent;
import org.apache.commons.vfs.FileName;
import org.apache.commons.vfs.FileObject;
import org.apache.commons.vfs.FileSystemManager;
import org.apache.commons.vfs.FileType;
import org.apache.commons.vfs.VFS;

/**
 * Command to list the contents of an archive file.
 *
 * @author Eric Van Dewoestine
 */
public class ArchiveListCommand
{
  public static final void main(String[] args)
    throws Exception
  {
    new ArchiveListCommand().execute(args);
  }

  public void execute(String[] args)
    throws Exception
  {
    String file = args[0];
    FileSystemManager manager = VFS.getManager();
    FileObject archive = manager.resolveFile(file);
    FileObject[] children = getFiles(archive);
    String[] results = processFiles(children);

    // the vfs file cache isn't very intelligent, so clear it.
    manager.getFilesCache().clear(archive.getFileSystem());

    for (String result : results){
      System.out.println(result);
    }
  }

  protected FileObject[] getFiles(FileObject archive)
    throws Exception
  {
    return archive.getChildren();
  }

  protected String[] processFiles(FileObject[] files)
    throws Exception
  {
    Arrays.sort(files, new Comparator<FileObject>(){
      private Collator collator =  Collator.getInstance();
      public int compare(FileObject o1, FileObject o2)
      {
        return collator.compare(
          o1.getName().getBaseName(),
          o2.getName().getBaseName());
      }
    });

    String[] results = new String[files.length];
    for (int ii = 0; ii < files.length; ii++){
      FileObject file = files[ii];
      FileType type = file.getType();
      FileContent content = file.getContent();
      FileName name = file.getName();
      results[ii] = new StringBuffer()
        .append(name.getPath()).append('|')
        .append(name.getBaseName()).append('|')
        .append(file.getURL()).append('|')
        .append(type).append('|')
        .append(type.hasContent() ? content.getSize() : 0).append('|')
        .append(type.hasContent() ?
            ArchiveUtils.formatTime(content.getLastModifiedTime()) : "")
        .toString();
    }
    return results;
  }
}
