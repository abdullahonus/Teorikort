# Backend API Dokümantasyonu - Ehliyet Sınavı Uygulaması

## 📋 Genel Bilgiler

Bu dokümantasyon, ehliyet sınavı uygulaması için gerekli tüm backend API endpoint'lerini içermektedir. Tüm API yanıtları aşağıdaki standart formatta döner:

```json
{
  "statuscode": 100,
  "description": "Başarılı",
  "data": {
    // API'ye özgü veri
  }
}
```

**Base URL**: `https://api.example.com/v1`

---

## 🔐 Authentication APIs

### 1. Kullanıcı Girişi
```
POST /auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "123456"
}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Giriş başarılı",
  "data": {
    "user": {
      "id": "user123",
      "email": "user@example.com",
      "name": "John",
      "lastname": "Doe",
      "phone": "+90 555 123 45 67",
      "photo_url": "https://example.com/avatar.jpg",
      "is_email_verified": true,
      "created_at": "2024-01-01T10:00:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_at": "2024-01-02T10:00:00Z"
  }
}
```

### 2. Kullanıcı Kaydı
```
POST /auth/register
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "123456",
  "name": "John",
  "lastname": "Doe",
  "phone": "+90 555 123 45 67"
}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Kayıt başarılı",
  "data": {
    "user": {
      "id": "user123",
      "email": "user@example.com",
      "name": "John",
      "lastname": "Doe",
      "phone": "+90 555 123 45 67",
      "photo_url": "https://example.com/default-avatar.jpg",
      "is_email_verified": false,
      "created_at": "2024-01-01T10:00:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_at": "2024-01-02T10:00:00Z"
  }
}
```

### 3. OTP Gönderimi
```
POST /auth/send-otp
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "OTP gönderildi",
  "data": {
    "message": "OTP kodunuz e-posta adresinize gönderildi",
    "expires_in": 300
  }
}
```

### 4. OTP Doğrulama
```
POST /auth/verify-otp
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "OTP doğrulandı",
  "data": {
    "verified": true,
    "message": "E-posta adresiniz doğrulandı"
  }
}
```

### 5. Şifre Sıfırlama
```
POST /auth/reset-password
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "otp": "123456",
  "new_password": "newpassword123"
}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Şifre başarıyla sıfırlandı",
  "data": {
    "message": "Şifreniz başarıyla güncellendi"
  }
}
```

---

## 🏠 Home Screen APIs

### 6. Ana Sayfa Verileri
```
GET /home
Headers: Authorization: Bearer {token}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Ana sayfa verileri",
  "data": {
    "welcome_message": {
      "message": "Hoş geldiniz!",
      "title": "Başarılı bir sınav için hazır mısınız?",
      "subtitle": "Bugün hangi konuyu çalışmak istiyorsunuz?"
    },
    "user_progress": {
      "total_exams_taken": 12,
      "success_rate": 85,
      "completed_tests": 8,
      "weak_topic": "traffic_signs",
      "strong_topic": "traffic_rules"
    },
    "daily_tip": {
      "id": 1,
      "title": "Günlük İpucu",
      "content": "Kavşaklarda öncelik hakkına sahip araçlara yol verin.",
      "category": "safety",
      "icon": "lightbulb"
    }
  }
}
```

### 7. Günlük İpucu
```
GET /daily-tips/today
Headers: Authorization: Bearer {token}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Günlük ipucu",
  "data": {
    "tip": {
      "id": 1,
      "title": "Güvenli Sürüş",
      "content": "Her zaman trafik kurallarına uyun ve güvenli sürüş yapın.",
      "category": "safety",
      "icon": "safety",
      "date": "2024-01-01"
    }
  }
}
```

---

## 📚 Exam Categories & Questions APIs

### 8. Sınav Kategorileri
```
GET /exam-categories
Headers: Authorization: Bearer {token}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Sınav kategorileri",
  "data": {
    "categories": [
      {
        "id": "traffic_signs",
        "title": {
          "tr": "Trafik İşaretleri",
          "en": "Traffic Signs"
        },
        "description": "Trafik işaretleri ve anlamları",
        "icon": "https://example.com/icons/traffic-signs.png",
        "total_questions": 50,
        "difficulty_levels": ["easy", "medium", "hard"]
      },
      {
        "id": "traffic_rules",
        "title": {
          "tr": "Trafik Kuralları", 
          "en": "Traffic Rules"
        },
        "description": "Temel trafik kuralları",
        "icon": "https://example.com/icons/traffic-rules.png",
        "total_questions": 45,
        "difficulty_levels": ["easy", "medium", "hard"]
      },
      {
        "id": "first_aid",
        "title": {
          "tr": "İlk Yardım",
          "en": "First Aid"
        },
        "description": "İlk yardım bilgileri",
        "icon": "https://example.com/icons/first-aid.png",
        "total_questions": 30,
        "difficulty_levels": ["easy", "medium", "hard"]
      },
      {
        "id": "vehicle_tech",
        "title": {
          "tr": "Motor ve Araç Tekniği",
          "en": "Vehicle Technology"
        },
        "description": "Araç tekniği ve bakım",
        "icon": "https://example.com/icons/vehicle-tech.png",
        "total_questions": 40,
        "difficulty_levels": ["easy", "medium", "hard"]
      }
    ]
  }
}
```

### 9. Kategori Sorularını Getir
```
GET /exam-categories/{category_id}/questions
Headers: Authorization: Bearer {token}
Query Parameters: 
  - limit: int (default: 10)
  - difficulty: string (easy|medium|hard)
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Kategori soruları",
  "data": {
    "category": {
      "id": "traffic_signs",
      "title": "Trafik İşaretleri"
    },
    "questions": [
      {
        "id": "q1",
        "question": "Aşağıdaki trafik işaretinin anlamı nedir?",
        "image_url": "https://example.com/questions/sign1.jpg",
        "options": [
          {
            "id": "a",
            "text": "Dur",
            "image_url": null
          },
          {
            "id": "b",
            "text": "Yavaşla",
            "image_url": null
          },
          {
            "id": "c",
            "text": "Sağa dön",
            "image_url": null
          },
          {
            "id": "d",
            "text": "Sola dön",
            "image_url": null
          }
        ],
        "correct_answer": "a",
        "explanation": "Bu işaret durması gerektiğini belirtir.",
        "difficulty": "easy"
      }
    ],
    "total_questions": 50,
    "current_page": 1,
    "per_page": 10
  }
}
```

### 10. Mock Sınav Sorularını Getir
```
GET /mock-exams/questions
Headers: Authorization: Bearer {token}
Query Parameters:
  - difficulty: string (easy|medium|hard)
  - count: int (default: 10)
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Mock sınav soruları",
  "data": {
    "exam_info": {
      "id": "mock_exam_001",
      "title": "Mock Sınav - Orta",
      "difficulty": "medium",
      "duration_minutes": 30,
      "total_questions": 10,
      "passing_score": 70
    },
    "questions": [
      {
        "id": "q1",
        "question": "Trafik işaretlerinde kırmızı renk neyi ifade eder?",
        "image_url": null,
        "options": [
          {
            "id": "a",
            "text": "Uyarı",
            "image_url": null
          },
          {
            "id": "b", 
            "text": "Yasak",
            "image_url": null
          },
          {
            "id": "c",
            "text": "Bilgi",
            "image_url": null
          },
          {
            "id": "d",
            "text": "Öncelik",
            "image_url": null
          }
        ],
        "correct_answer": "b",
        "explanation": "Kırmızı renk yasak ve durdurma işaretlerinde kullanılır.",
        "difficulty": "medium"
      }
    ]
  }
}
```

---

## 📊 Exam Results APIs

### 11. Sınav Sonucu Kaydet
```
POST /exam-results
Headers: Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "exam_id": "mock_exam_001",
  "category": "traffic_signs",
  "exam_type": "mock", // "mock" | "category" | "random"
  "difficulty": "medium",
  "total_questions": 10,
  "correct_answers": 8,
  "wrong_answers": 2,
  "empty_answers": 0,
  "score_percentage": 80,
  "duration_seconds": 600,
  "answers": [
    {
      "question_id": "q1",
      "selected_answer": "b",
      "correct_answer": "b",
      "is_correct": true
    },
    {
      "question_id": "q2", 
      "selected_answer": "a",
      "correct_answer": "c",
      "is_correct": false
    }
  ],
  "completed_at": "2024-01-01T10:30:00Z"
}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Sınav sonucu kaydedildi",
  "data": {
    "result": {
      "id": "result_001",
      "exam_id": "mock_exam_001",
      "user_id": "user123",
      "category": "traffic_signs",
      "exam_type": "mock",
      "total_questions": 10,
      "correct_answers": 8,
      "score_percentage": 80,
      "duration_seconds": 600,
      "passed": true,
      "completed_at": "2024-01-01T10:30:00Z",
      "rank": 25,
      "improvement": "+5%" // Önceki sonuca göre
    }
  }
}
```

### 12. Kullanıcı Sınav Sonuçları
```
GET /exam-results
Headers: Authorization: Bearer {token}
Query Parameters:
  - category: string (optional)
  - limit: int (default: 10)
  - page: int (default: 1)
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Sınav sonuçları",
  "data": {
    "results": [
      {
        "id": "result_001",
        "exam_id": "mock_exam_001",
        "category": "traffic_signs",
        "exam_type": "mock",
        "title": "Trafik İşaretleri - Mock",
        "total_questions": 10,
        "correct_answers": 8,
        "score_percentage": 80,
        "duration_seconds": 600,
        "passed": true,
        "completed_at": "2024-01-01T10:30:00Z",
        "difficulty": "medium"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 10,
      "total": 25,
      "total_pages": 3
    }
  }
}
```

---

## 📈 Statistics APIs

### 13. Kullanıcı İstatistikleri
```
GET /statistics
Headers: Authorization: Bearer {token}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Kullanıcı istatistikleri",
  "data": {
    "overall_stats": {
      "total_exams_taken": 25,
      "total_available_exams": 100,
      "average_score": 75,
      "best_score": 95,
      "total_study_time": 1200, // dakika
      "total_questions_answered": 250,
      "correct_answers_rate": 80,
      "current_streak": 5,
      "longest_streak": 12
    },
    "category_performance": [
      {
        "category_id": "traffic_signs",
        "name": "Trafik İşaretleri",
        "exams_taken": 8,
        "average_score": 85,
        "best_score": 95,
        "progress": 85,
        "total_questions": 120,
        "correct_answers": 102,
        "improvement_trend": "up", // "up" | "down" | "stable"
        "weak_areas": ["Uyarı işaretleri", "Öncelik işaretleri"],
        "strong_areas": ["Yasaklama işaretleri"]
      },
      {
        "category_id": "traffic_rules",
        "name": "Trafik Kuralları",
        "exams_taken": 6,
        "average_score": 70,
        "best_score": 85,
        "progress": 70,
        "total_questions": 90,
        "correct_answers": 63,
        "improvement_trend": "stable",
        "weak_areas": ["Kavşak kuralları"],
        "strong_areas": ["Hız sınırları", "Park kuralları"]
      }
    ],
    "recent_exams": [
      {
        "id": "result_001",
        "title": "Trafik İşaretleri",
        "category": "traffic_signs",
        "completed_at": "2024-01-01T10:30:00Z",
        "score": 80,
        "duration_minutes": 10,
        "correct_answers": 8,
        "total_questions": 10,
        "improvement": "+5%"
      }
    ]
  }
}
```

### 14. Kategori Detay İstatistikleri
```
GET /statistics/categories/{category_id}
Headers: Authorization: Bearer {token}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Kategori detay istatistikleri",
  "data": {
    "category": {
      "id": "traffic_signs",
      "name": "Trafik İşaretleri",
      "description": "Trafik işaretleri ve anlamları"
    },
    "performance": {
      "exams_taken": 8,
      "average_score": 85,
      "best_score": 95,
      "worst_score": 60,
      "total_questions": 120,
      "correct_answers": 102,
      "improvement_rate": 15,
      "time_spent": 240, // dakika
      "difficulty_performance": {
        "easy": {
          "average_score": 95,
          "exams_taken": 3
        },
        "medium": {
          "average_score": 85,
          "exams_taken": 4
        },
        "hard": {
          "average_score": 70,
          "exams_taken": 1
        }
      }
    },
    "weak_areas": [
      {
        "topic": "Uyarı işaretleri",
        "correct_rate": 60,
        "total_questions": 20,
        "recommendation": "Bu konuyu daha fazla çalışmanız önerilir"
      }
    ],
    "strong_areas": [
      {
        "topic": "Yasaklama işaretleri",
        "correct_rate": 95,
        "total_questions": 30
      }
    ]
  }
}
```

---

## 🏆 Leaderboard APIs

### 15. Lider Tablosu
```
GET /leaderboard
Headers: Authorization: Bearer {token}
Query Parameters:
  - period: string (weekly|monthly|all_time) default: weekly
  - limit: int (default: 50)
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Lider tablosu",
  "data": {
    "leaderboard": [
      {
        "rank": 1,
        "user_id": "user456",
        "name": "Ali Veli",
        "photo_url": "https://example.com/avatars/user456.jpg",
        "score": 950,
        "total_exams": 20,
        "average_score": 90,
        "is_current_user": false
      },
      {
        "rank": 2,
        "user_id": "user123",
        "name": "John Doe",
        "photo_url": "https://example.com/avatars/user123.jpg", 
        "score": 920,
        "total_exams": 18,
        "average_score": 85,
        "is_current_user": true
      }
    ],
    "current_user": {
      "rank": 2,
      "score": 920,
      "total_users": 1250
    },
    "period": "weekly",
    "last_updated": "2024-01-01T12:00:00Z"
  }
}
```

### 16. Kullanıcı Sıralaması
```
GET /leaderboard/my-rank
Headers: Authorization: Bearer {token}
Query Parameters:
  - period: string (weekly|monthly|all_time) default: weekly
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Kullanıcı sıralaması",
  "data": {
    "current_rank": 25,
    "total_users": 1250,
    "score": 750,
    "percentile": 98.0,
    "rank_change": "+5", // Önceki döneme göre
    "near_users": [
      {
        "rank": 23,
        "name": "User A",
        "score": 780
      },
      {
        "rank": 24,
        "name": "User B", 
        "score": 765
      },
      {
        "rank": 25,
        "name": "John Doe",
        "score": 750,
        "is_current_user": true
      },
      {
        "rank": 26,
        "name": "User C",
        "score": 740
      }
    ]
  }
}
```

---

## 📚 Topics & Educational Content APIs

### 17. Konular Listesi
```
GET /topics
Headers: Authorization: Bearer {token}
Query Parameters:
  - language: string (tr|en) default: tr
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Konular listesi",
  "data": {
    "topics": [
      {
        "id": "topic_001",
        "title": "Trafik İşaretleri",
        "description": "Trafik işaretleri ve anlamları hakkında detaylı bilgi",
        "image_url": "https://example.com/topics/traffic-signs.jpg",
        "sub_topics_count": 5,
        "images_count": 25,
        "estimated_read_time": 15, // dakika
        "difficulty": "beginner"
      },
      {
        "id": "topic_002",
        "title": "Trafik Kuralları",
        "description": "Temel trafik kuralları ve uygulamaları",
        "image_url": "https://example.com/topics/traffic-rules.jpg",
        "sub_topics_count": 8,
        "images_count": 30,
        "estimated_read_time": 25,
        "difficulty": "intermediate"
      }
    ]
  }
}
```

### 18. Konu Detayı
```
GET /topics/{topic_id}
Headers: Authorization: Bearer {token}
Query Parameters:
  - language: string (tr|en) default: tr
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Konu detayı",
  "data": {
    "topic": {
      "id": "topic_001",
      "title": "Trafik İşaretleri",
      "description": "Trafik işaretleri ve anlamları hakkında detaylı bilgi",
      "image_url": "https://example.com/topics/traffic-signs.jpg",
      "images": [
        "https://example.com/topics/signs1.jpg",
        "https://example.com/topics/signs2.jpg"
      ],
      "sub_topics": [
        {
          "id": "subtopic_001",
          "title": "Uyarı İşaretleri",
          "content": "<h3>Uyarı İşaretleri</h3><p>Uyarı işaretleri sürücüleri yaklaşmakta olan tehlike...</p>",
          "images": [
            "https://example.com/subtopics/warning1.jpg",
            "https://example.com/subtopics/warning2.jpg"
          ],
          "order": 1
        },
        {
          "id": "subtopic_002",
          "title": "Yasaklama İşaretleri",
          "content": "<h3>Yasaklama İşaretleri</h3><p>Yasaklama işaretleri belirli hareketleri yasaklar...</p>",
          "images": [
            "https://example.com/subtopics/prohibition1.jpg"
          ],
          "order": 2
        }
      ]
    }
  }
}
```

### 19. Alt Konu Detayı
```
GET /topics/{topic_id}/subtopics/{subtopic_id}
Headers: Authorization: Bearer {token}
Query Parameters:
  - language: string (tr|en) default: tr
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Alt konu detayı",
  "data": {
    "subtopic": {
      "id": "subtopic_001",
      "title": "Uyarı İşaretleri",
      "content": "<h3>Uyarı İşaretleri</h3><p>Uyarı işaretleri sürücüleri yaklaşmakta olan tehlike hakkında uyarır...</p>",
      "images": [
        "https://example.com/subtopics/warning1.jpg",
        "https://example.com/subtopics/warning2.jpg"
      ],
      "related_questions": [
        {
          "id": "q1",
          "question": "Uyarı işaretlerinin şekli nedir?",
          "category": "traffic_signs"
        }
      ],
      "next_subtopic": {
        "id": "subtopic_002",
        "title": "Yasaklama İşaretleri"
      },
      "previous_subtopic": null
    }
  }
}
```

---

## 👤 User Profile APIs

### 20. Kullanıcı Profili
```
GET /user/profile
Headers: Authorization: Bearer {token}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Kullanıcı profili",
  "data": {
    "user": {
      "id": "user123",
      "email": "user@example.com",
      "name": "John",
      "lastname": "Doe",
      "phone": "+90 555 123 45 67",
      "photo_url": "https://example.com/avatars/user123.jpg",
      "is_email_verified": true,
      "created_at": "2024-01-01T10:00:00Z",
      "last_login": "2024-01-01T10:00:00Z",
      "preferred_language": "tr",
      "settings": {
        "notifications_enabled": true,
        "sound_enabled": true,
        "theme": "system" // "light" | "dark" | "system"
      }
    }
  }
}
```

### 21. Profil Güncelle
```
PUT /user/profile
Headers: Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "John",
  "lastname": "Doe",
  "phone": "+90 555 123 45 67",
  "preferred_language": "tr"
}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Profil güncellendi",
  "data": {
    "user": {
      "id": "user123",
      "email": "user@example.com",
      "name": "John",
      "lastname": "Doe",
      "phone": "+90 555 123 45 67",
      "photo_url": "https://example.com/avatars/user123.jpg",
      "is_email_verified": true,
      "preferred_language": "tr",
      "updated_at": "2024-01-01T11:00:00Z"
    }
  }
}
```

### 22. Profil Fotoğrafı Yükle
```
POST /user/profile/photo
Headers: Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body:**
```
photo: [file]
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Profil fotoğrafı yüklendi",
  "data": {
    "photo_url": "https://example.com/avatars/user123_new.jpg",
    "uploaded_at": "2024-01-01T11:00:00Z"
  }
}
```

### 23. Kullanıcı Ayarları Güncelle
```
PUT /user/settings
Headers: Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "notifications_enabled": true,
  "sound_enabled": false,
  "theme": "dark",
  "preferred_language": "en"
}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Ayarlar güncellendi",
  "data": {
    "settings": {
      "notifications_enabled": true,
      "sound_enabled": false,
      "theme": "dark",
      "preferred_language": "en"
    },
    "updated_at": "2024-01-01T11:00:00Z"
  }
}
```

---

## 🔍 Search APIs

### 24. Soru Arama
```
GET /search/questions
Headers: Authorization: Bearer {token}
Query Parameters:
  - q: string (arama terimi)
  - category: string (optional)
  - difficulty: string (optional)
  - limit: int (default: 10)
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Arama sonuçları",
  "data": {
    "query": "trafik işareti",
    "results": [
      {
        "id": "q1",
        "question": "Aşağıdaki trafik işaretinin anlamı nedir?",
        "category": "traffic_signs",
        "difficulty": "easy",
        "relevance_score": 0.95
      }
    ],
    "total_results": 25,
    "search_time": 0.023
  }
}
```

---

## 📊 Analytics APIs

### 25. Uygulama İstatistikleri (Admin)
```
GET /analytics/app-stats
Headers: Authorization: Bearer {admin_token}
```

**Response:**
```json
{
  "statuscode": 100,
  "description": "Uygulama istatistikleri",
  "data": {
    "total_users": 15000,
    "active_users_today": 1200,
    "active_users_week": 5000,
    "total_exams_taken": 50000,
    "avg_session_duration": 25, // dakika
    "most_popular_category": "traffic_signs",
    "avg_success_rate": 78
  }
}
```

---

## 🚨 Error Responses

Tüm API'lerde hata durumlarında aşağıdaki format kullanılır:

### 400 Bad Request
```json
{
  "statuscode": 400,
  "description": "Geçersiz istek",
  "data": {
    "error": "validation_error",
    "message": "E-posta adresi geçerli değil",
    "details": {
      "field": "email",
      "code": "invalid_format"
    }
  }
}
```

### 401 Unauthorized
```json
{
  "statuscode": 401,
  "description": "Yetkilendirme hatası",
  "data": {
    "error": "unauthorized",
    "message": "Geçerli bir token gerekli"
  }
}
```

### 404 Not Found
```json
{
  "statuscode": 404,
  "description": "Bulunamadı",
  "data": {
    "error": "not_found",
    "message": "Belirtilen kaynak bulunamadı"
  }
}
```

### 500 Internal Server Error
```json
{
  "statuscode": 500,
  "description": "Sunucu hatası",
  "data": {
    "error": "internal_error",
    "message": "Bir sunucu hatası oluştu"
  }
}
```

---

## 📋 Status Codes

- **100**: Başarılı
- **400**: Geçersiz istek
- **401**: Yetkilendirme hatası
- **403**: Yasaklı
- **404**: Bulunamadı
- **409**: Çakışma (örn: e-posta zaten mevcut)
- **422**: İşlenemez entity (validation error)
- **500**: Sunucu hatası

---

## 🔄 Rate Limiting

- **Authentication endpoints**: 5 istek/dakika
- **General endpoints**: 100 istek/dakika
- **Upload endpoints**: 10 istek/dakika

---

## 📝 Notes

1. Tüm tarih/saat değerleri ISO 8601 formatında (UTC)
2. Dosya yüklemeleri için maximum 5MB limit
3. Pagination için `limit` ve `page` parametreleri kullanılır
4. Çoklu dil desteği için `language` parametresi (tr/en)
5. Token süreleri: 24 saat (refresh token ile yenilenebilir) 

## 🚧 Eksik / Yapılandırılmamış API'ler

Aşağıdaki özellikler projede kod olarak mevcut veya planlanmış ancak backend tarafında henüz karşılıkları bu dokümantasyonda tanımlanmamıştır:

1. **Raporlama Sistemi**
   - `POST /reports`: Soruları raporlamak için kullanılacak endpoint.

2. **Çalışma Kitabı & Kaydedilenler**
   - `GET /workbooks`: Kullanıcının kaydettiği veya üzerinde çalıştığı kitaplar.

3. **Paketler & Satın Alma**
   - `GET /packages`: Uygulama içi paketler.
   - `GET /packages/{id}`: Paket detayı.

4. **Trafik İşaretleri Kütüphanesi**
   - `GET /signs`: Tüm trafik işaretlerini listeleyecek endpoint.
   - `GET /signs/{id}`: Belirli bir işaretin detayı.

5. **Kullanıcı Ayarları**
   - `GET /user/settings`: Kullanıcı tercihlerini getiren endpoint.

6. **Daha Detaylı Profil Bilgisi**
   - `GET /auth/me`: Mevcut oturum bilgilerini doğrulamak için.
   - `POST /auth/logout`: Sunucu taraflı oturum kapatma.

7. **Kategori Bazlı Mock Sınavlar**
   - Şu an `/mock-exams/questions` genel sınav veriyor. Spesifik kategori denemeleri için `/exam-categories/{id}/mock-exam` planlanabilir.
