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

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;

import java.util.regex.Pattern;

import org.apache.commons.vfs.FileObject;
import org.apache.commons.vfs.FileSystemManager;
import org.apache.commons.vfs.VFS;

/**
 * Command to read a file from a commons vfs compatable path.
 *
 * @author Eric Van Dewoestine
 */
public class ArchiveReadCommand
{
  private static final String URI_PREFIX = "file://";
  private static final Pattern WIN_PATH = Pattern.compile("^/[a-zA-Z]:/.*");

  public static final void main(String[] args)
    throws Exception
  {
    new ArchiveReadCommand().execute(args);
  }

  public void execute(String[] args)
    throws Exception
  {
    InputStream in = null;
    OutputStream out = null;
    FileSystemManager fsManager = null;
    try{
      String file = args[0];

      fsManager = VFS.getManager();
      FileObject fileObject = fsManager.resolveFile(file);
      FileObject tempFile = fsManager.resolveFile(
          System.getProperty("java.io.tmpdir") +
          "/vim-archive" +
          fileObject.getName().getPath());

      // the vfs file cache isn't very intelligent, so clear it.
      fsManager.getFilesCache().clear(fileObject.getFileSystem());
      fsManager.getFilesCache().clear(tempFile.getFileSystem());

      // NOTE: FileObject.getName().getPath() does not include the drive
      // information.
      String path = tempFile.getName().getURI().substring(URI_PREFIX.length());
      // account for windows uri which has an extra '/' in front of the drive
      // letter (file:///C:/blah/blah/blah).
      if (WIN_PATH.matcher(path).matches()){
        path = path.substring(1);
      }

      //if(!tempFile.exists()){
        tempFile.createFile();

        in = fileObject.getContent().getInputStream();
        out = tempFile.getContent().getOutputStream();

        int n = 0;
        byte[] buffer = new byte[1024 * 4];
        while ((n = in.read(buffer)) != -1) {
          out.write(buffer, 0, n);
        }

        //new File(path).deleteOnExit();
      //}

      System.out.println(path);
    }finally{
      try{
        in.close();
      }catch(Exception e){
      }
      try{
        out.close();
      }catch(Exception e){
      }
    }
  }
}
