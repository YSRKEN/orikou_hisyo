#ifndef ClipboardModuleIncluded
#define ClipboardModuleIncluded
#module ClipboardModule

#uselib "kernel32.dll"      ;���O���[�o��������
#func GlobalAlloc   "GlobalAlloc"   int, int    ;�J���K�{
#func GlobalFree    "GlobalFree"    int
#func GlobalLock    "GlobalLock"    int         ;����K�{
#func GlobalUnlock  "GlobalUnlock"  int
#func GlobalSize    "GlobalSize"    int
#define GMEM_FIXED      0           ;�Œ胁�������m�ۂ���
#define GMEM_MOVEABLE   2           ;�ړ��\���������m�ۂ���
#define GMEM_ZEROINIT   $40         ;0�ŏ���������
#define GMEM_SHARE      8192        ;DDE�֐����N���b�v�{�[�h�Ŏg�p����ꍇ�w�肷��
#define GHND            $42         ;GMEM_MOVEABLE + GMEM_ZEROINIT

#uselib "kernel32.dll"      ;���t�@�C���p�X�ϊ�
#func GetFullPathName "GetFullPathNameA" str, int, var, nullptr

#uselib "user32.dll"
#func OpenClipboard     "OpenClipboard"     int
#func CloseClipboard    "CloseClipboard"
#func GetClipboardData  "GetClipboardData"  int
#func SetClipboardData  "SetClipboardData"  int, int
#func EmptyClipboard    "EmptyClipboard"
#func IsClipboardFormatAvailable "IsClipboardFormatAvailable" int
#define CF_TEXT     1
#define CF_BITMAP   2
#define CF_HDROP    15
#func RegisterClipboardFormat "RegisterClipboardFormatA" str
#define CFSTR_PREFERREDDROPEFFECT   "Preferred DropEffect"
#define DROPEFFECT_NONE             0
#define DROPEFFECT_COPY             1   ;�R�s�[��������s�ł��܂��B
#define DROPEFFECT_MOVE             2   ;�ړ���������s�ł��܂��B
#define DROPEFFECT_LINK             4   ;�h���b�v���ꂽ�f�[�^�ƌ��̃f�[�^�Ƃ̃����N���m���ł��܂��B
#define DROPEFFECT_SCROLL   $80000000   ;�h���b�O �X�N���[����������s�ł��邱�Ƃ������܂��B

#uselib "USER32.dll"
#func GetDC     "GetDC"     int
#func ReleaseDC "ReleaseDC" int, int

#uselib "GDI32.dll"
#func CreateCompatibleDC "CreateCompatibleDC" int
#func DeleteDC          "DeleteDC"      int
#func SelectObject      "SelectObject"  int, int
#func DeleteObject      "DeleteObject"  int
#func CreateCompatibleBitmap "CreateCompatibleBitmap" int, int, int
#func BitBlt            "BitBlt"        int, int, int, int, int, int, int, int, int
#func GetClipBox        "GetClipBox"    int, var

#uselib "shell32.dll"       ;���h���b�O���h���b�v������API
#func DragQueryFile "DragQueryFileA" int, int, var, int

#deffunc ClipB_GetText var t
    t = ""
    IsClipboardFormatAvailable CF_TEXT  : if stat == 0  : return ; �e�L�X�g�͂Ȃ�
    OpenClipboard hwnd ; �N���b�v�{�[�h�J��
    if stat {
        GetClipboardData CF_TEXT  : ib = stat   ;   �O���[�o���������̃n���h���擾
        GlobalSize ib  : ib(1) = stat   ;   �������T�C�Y
        GlobalLock ib  : ib(2) = stat   ;   ���������b�N
        dupptr dp , ib(2) , ib(1) , 2
        t = dp  ;           �f�[�^����ɓ��ꂽ�I
        GlobalUnlock ib ;   �������A�����b�N
        CloseClipboard  ;   �N���b�v�{�[�h�����
    }
    return

#deffunc ClipB_SetText str s
    GlobalAlloc GMEM_ZEROINIT | GMEM_SHARE, strlen(s) + 2 ;�O���[�o���������m��
    ib = stat                       ;�O���[�o���������̃n���h��
    if ib == 0  : return 0          ;�V�b�p�C�I�H
    GlobalLock ib  : ib(1) = stat   ;���������b�N
    dupptr dp, ib(1), strlen(s) + 2, 2  : dp = s    ;�i�[�B
    GlobalUnlock ib                 ;�������A�����b�N
    OpenClipboard hwnd              ;�N���b�v�{�[�h���J��
    if stat {
        EmptyClipboard              ;�N���b�v�{�[�h����ɂ���
        SetClipboardData CF_TEXT, ib;�O���[�o����������n��
        CloseClipboard              ;�N���b�v�{�[�h�����
        return 1                    ;�O���[�o���������̓N���b�v�{�[�h�̊Ǌ��ɁB
    }
    GlobalFree ib   ;�n���Ȃ������ꍇ�͎��͂ŊJ������B
    return 0

#deffunc ClipB_GetBmpSize var x, var y
    x = 0  : y = 0
    IsClipboardFormatAvailable CF_BITMAP  : if stat == 0  : return  ;�摜����H
    OpenClipboard hwnd
    if stat {
        GetClipboardData CF_BITMAP
        ib = stat, 0, 0, 0, 0, 0
        SelectObject hdc, ib(0)  : ib(1) = stat ;�����ł�������B
        GetClipBox   hdc, ib(2)     ;����ő傫������B
        SelectObject hdc, ib(1)     ;���������߂�
        CloseClipboard
        x = ib(4)  : y = ib(5)      ;����
    }
    return

#deffunc ClipB_GetBmp int x, int y, int w, int h
    IsClipboardFormatAvailable CF_BITMAP
    if stat == 0  : return 0    ;clipboard��bitmap���Ȃ�

    OpenClipboard hwnd
    if stat {
        GetClipboardData CF_BITMAP  ;�r�b�g�}�b�v�̃n���h�����擾
        ib = stat, 0, 0, 0, 0, 0, 0
        ;�N���b�v�{�[�h��HSP�ł̓r�b�g�}�b�v�̌`�����Ⴄ...
        CreateCompatibleDC hdc  : ib(1) = stat  ;�V�����f�o�C�X�R���e�L�X�g�쐬
        SelectObject ib.1, ib   : ib(2) = stat  ;BITMAP�ύX
        BitBlt hdc, ginfo(22), ginfo(23), w, h, ib(1), x, y, $00CC0020  ;�R�s�[
        SelectObject ib(1), ib(2)   ;BITMAP���ǂ�
        DeleteDC ib(1)              ;�f�o�C�X�R���e�L�X�g�폜
        CloseClipboard  : return 1
    }
    return 0

#deffunc ClipB_SetBmp int x, int y, int w, int h
    // ib = HBitmap, DummyHBitmap, WorkHDC, miracleHDC
    GetDC                               : ib(3) = stat
    CreateCompatibleDC      ib(3)       : ib(2) = stat
    CreateCompatibleBitmap  ib(3), w, h : ib(0) = stat
    ReleaseDC               0, ib(3)
    SelectObject            ib(2), ib   : ib(1) = stat
    BitBlt  ib(2), 0, 0, w, h, hdc, x, y, $00CC0020
    SelectObject            ib(2), ib(1)
    DeleteDC                ib(2)

    OpenClipboard hwnd
    if stat {
        EmptyClipboard
        SetClipboardData CF_BITMAP, ib(0)
        CloseClipboard
    }
    DeleteObject ib(0)
    return

#deffunc ClipB_GetFile var t    ;�N���b�v�{�[�h����t�@�C���p�X�Ƃ��Ă݂悤
    t = ""  : sb = ""
    OpenClipboard hwnd
    if stat == 0  : return 0                ;�N���b�v�{�[�h���J���Ȃ�����

    ib = 0, 0, 0, 0, 0      ;return�l, GMhandle, GMpinter, FileCnt, temp

    IsClipboardFormatAvailable CF_HDROP             ;�t�@�C�����邩�ȁH
    if stat {                                       ;�t�@�C����������_(^ ^)�^
        GetClipBoardData CF_HDROP  : ib(1) = stat   ;�t�@�C�����̋l�܂���GM���Ɓ[
        ;if ib(1) == 0                                  ;�H�L����Č������̂ɂ��I
        GlobalLock ib(1)  : ib(2) = stat
        DragQueryFile ib(2), -1, ib(3), 0           ;�t�@�C�����������[
        ib(3) = stat
        repeat ib(3)
            DragQueryFile ib(2), cnt, sb, 0         ;�܂��͕����������擾
            ib(4) = stat + 1  : memexpand sb, ib(4) ;���������v�H
            DragQueryFile ib(2), cnt, sb, ib(4)     ;�t�@�C�������擾����
            t += sb + "\n"                          ;�A���I
        loop
        GlobalUnlock ib(1)
        ib = ib(3)                                  ;�t�@�C���ꗗ�擾�����B
    }
    CloseClipboard                          ;�J������߂�͓S���B
    return ib

#defcfunc ClipB_GetFileMode
    OpenClipboard hwnd
    if stat == 0  : return 0                        ;�N���b�v�{�[�h���J���Ȃ�����

    ib = 0, 0, 0
    RegisterClipboardFormat CFSTR_PREFERREDDROPEFFECT
    ib(1) = stat                                    ;DragEffect�̎��ʎq����
    if ib(1) {                                      ;���s���Ă��Ƃ͍l���ɂ�������...
        IsClipboardFormatAvailable ib(1)            ;������ʂ��邩�ȁH
        if stat {                                   ;�������B
            GetClipBoardData ib(1)  : ib(2) = stat  ;�n���h�����������
            GlobalLock ib(2)                        ;�������L���b�`����
            dupptr dp, stat, 4, 4                   ;�^�[�Q�b�g���b�N�I���I
            ib = dp                                 ;���W����
            GlobalUnlock ib(2)                      ;�����������[�X����
        }
    }
    CloseClipboard
    return ib

#deffunc ClipB_SetFile str s, int m, local t
    ib    = 0, 0, 0     ;hMem(path), hMem(effect), eff���ʎq
    ib(3) = 0, 0, 0     ;file��, file������null�R�~, tempo
    t = s               ;�t�@�C���p�X�ꗗ
    sb = ""
    notesel t

    repeat noteinfo(0)              ;�܂��͉������炦
        noteget sb, cnt
        GetFullPathName sb, 0, sb       ;�����̕ϐ��̓_�~�[(�ʂ��)
        ib(5) = stat                    ;�t���p�X�̕�����(�ʂ�R�~)
        memexpand sb, ib(5)             ;�t���p�X���m���Ɋi�[�ł���悤��
        GetFullPathName sb, ib(5), sb   ;��΃p�X�Q�g�[
        noteadd sb, cnt, 1              ;��΃p�X�����Ƃ̈ʒu�ɖ߂�
        ib(4) += ib(5)                  ;�t�@�C���p�X������(null��)�ɉ��Z
        ib(3) ++                        ;�t�@�C�������₷
    loop

    GlobalAlloc GMEM_ZEROINIT | GMEM_SHARE, ib(4) + 22  ;GM�m��(����N��)
    ib = stat
    GlobalLock ib
    dupptr dp, stat, ib(4) + 22, 4  ;���[��(Null)���͂���Ȃ���B
    dp    = 20          ;�t�@�C�����܂ł�offset
    dp(1) = 0, 0        ;���WX,Y
    dp(3) = 0           ;�ꏊ(�N���C�A���g�̈�H)
    dp(4) = 0           ;�p�X�i�[���@(0:���� 1:���㎮)
    ib(5) = 20
    repeat ib(3)
        noteget sb, cnt
        memcpy dp, sb, strlen(sb) + 1, ib(5);���ł�Null���ꏏ�ɁB
        ib(5) += strlen(sb) + 1
    loop
    poke dp, ib(5), 0   ;�O�̂��߁A�ӂ�(�����̃k���k��)����B
    GlobalUnlock ib

    noteunsel

    GlobalAlloc GMEM_ZEROINIT | GMEM_SHARE, 4   ;GM�m��
    ib(1) = stat
    GlobalLock ib(1)
    dupptr dp, stat, 4, 4
    dp = m
    GlobalUnlock ib(1)

    RegisterClipboardFormat CFSTR_PREFERREDDROPEFFECT
    ib(2) = stat                    ;DragEffect�̎��ʎq����

    OpenClipboard hwnd              ;�N���b�v�{�[�h���J��
    if stat {
        EmptyClipboard              ;�N���b�v�{�[�h����ɂ���
        SetClipboardData CF_HDROP, ib;�O���[�o����������n��
        SetClipboardData ib(2), ib(1);�O���[�o����������n��
        CloseClipboard              ;�N���b�v�{�[�h�����
        return ib(3)    ;�O���[�o���������̓N���b�v�{�[�h�̊Ǌ��ɁB
    }
    GlobalFree ib       ;�����t�����s�����ꍇ�͎��͂ŊJ������B
    GlobalFree ib(1)    ;���������B
    return 0

#deffunc ClipB_SetEmpty
    OpenClipboard hwnd
    if stat == 0  : return 0
    EmptyClipboard
    CloseClipboard
    return 1

; http://www.tvg.ne.jp/menyukko/ ; Copyright(C) 2005-2011 �ߓ��a All rights reserved.
#global
#endif
