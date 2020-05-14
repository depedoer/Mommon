// This is part of the Mommon Library
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// This software is distributed without any warranty.
//
// @author Domenico Mammola (mimmo71@gmail.com - www.mammola.net)
//
unit mImageToPdf;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

function ConvertImageToPdf(const aSourceImageFile, aDestinationPdfFile : String; const aEnlargeToPage : boolean): boolean;

implementation


uses
  sysutils,
  fpreadjpeg,
  fppdf,
  fpparsettf;

function ConvertImageToPdf(const aSourceImageFile, aDestinationPdfFile: String; const aEnlargeToPage : boolean): boolean;
var
  doc : TPDFDocument;
  page : TPDFPage;
  sec : TPDFSection;
  img, w, h, pageWidth, pageHeight, imgWidth, imgHeight : integer;
begin
  Result := false;
  doc := TPDFDocument.Create(Nil);
  try
    doc.Infos.CreationDate:= Now;
    doc.Options:= [poCompressFonts, poCompressText, poCompressImages];
    doc.StartDocument;
    sec := doc.Sections.AddSection; // we always need at least one section

    img := doc.Images.AddFromFile(aSourceImageFile);

    page := doc.Pages.AddPage;
    page.PaperType:= ptA4;
    page.UnitOfMeasure:= uomPixels;
    page.Orientation:= ppoPortrait;
    sec.AddPage(page);

    pageWidth := round(page.Paper.Printable.R - page.Paper.Printable.L);
    pageHeight := round(page.Paper.Printable.B - page.Paper.Printable.T);
    imgWidth := doc.Images[0].Width;
    imgHeight :=  doc.Images[0].Height;

    if aEnlargeToPage then
    begin
      page.DrawImage(1, 1, pageWidth, pageHeight, img);
    end
    else
    begin
      w := imgWidth;
      h := imgHeight;
      if imgWidth > pageWidth then
      begin
        h := round(h * (pageWidth / imgWidth));
        w := pageWidth;
        if h > pageHeight then
        begin
          w := round(w * (pageHeight / h));
          h := pageHeight;
        end;

      end;
      page.DrawImage(1, 1, w, h, img);
    end;

    doc.SaveToFile(aDestinationPdfFile);
  finally
    doc.Free;
  end;
  Result := true;
end;

end.